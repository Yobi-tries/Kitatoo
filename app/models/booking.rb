class Booking < ApplicationRecord
  belongs_to :availability
  belongs_to :client, class_name: "User"

  validates :availability_id, uniqueness: {
    conditions: -> { where.not(status: :cancelled) },
    message: "has already been booked"
  }
  validates :description, presence: true
  validate :max_active_bookings_per_artist, on: :create

  enum :status, { selected: 0, artist_confirmed: 1, confirmed: 2, cancelled: 3 }

  after_update_commit :broadcast_status_change

  private

  def broadcast_status_change
    conversation = Conversation.find_by(
      client_id: client_id,
      artist_profile: availability.artist_profile
    )
    return unless conversation

    Turbo::StreamsChannel.broadcast_refresh_to(conversation)
  end

  def max_active_bookings_per_artist
    return unless client && availability&.artist_profile

    exists = Booking.joins(:availability)
      .where.not(status: :cancelled)
      .where(client: client, availabilities: { artist_profile_id: availability.artist_profile_id })
      .exists?

    if exists
      errors.add(:base, "You can only have 1 ongoing booking with this artist.")
    end
  end
end
