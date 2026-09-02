class Booking < ApplicationRecord
  belongs_to :availability
  belongs_to :client, class_name: "User"

  validates :availability_id, uniqueness: {
    conditions: -> { where.not(status: :cancelled) },
    message: "has already been booked"
  }
  validates :description, presence: true
  validate :max_active_bookings_per_artist, on: :create

  enum :status, { selected: 0, artist_confirmed: 1, confirmed: 2, cancelled: 3, completed: 4 }

  after_create_commit :mark_creator_notified
  after_update_commit :broadcast_status_change
  after_update_commit :notify_other_party, if: :saved_change_to_status?

  def mark_notified!(user)
    artist_user_id = availability.artist_profile.user_id
    if user.id == client_id
      update_column(:client_notified_at, Time.current)
    elsif user.id == artist_user_id
      update_column(:artist_notified_at, Time.current)
    end
  end

  def unnotified_for?(user)
    artist_user_id = availability.artist_profile.user_id
    notified_at = if user.id == client_id
      client_notified_at
    elsif user.id == artist_user_id
      artist_notified_at
    end

    return false if notified_at.nil?

    updated_at > notified_at
  end

  private

  def mark_creator_notified
    update_column(:client_notified_at, Time.current)
  end

  def notify_other_party
    now = Time.current
    case status
    when "artist_confirmed"
      # Artist acted → mark artist as seen, client will see the dot
      update_column(:artist_notified_at, now)
    when "selected"
      # Client acted → mark client as seen, artist will see the dot
      update_column(:client_notified_at, now)
    when "confirmed"
      # Client accepted → mark client as seen, artist will see the dot
      update_column(:client_notified_at, now)
    when "completed", "cancelled"
      # Both parties are aware of terminal actions
      update_columns(client_notified_at: now, artist_notified_at: now)
    end
  end

  def broadcast_status_change
    conversation = Conversation.find_by(
      client_id: client_id,
      artist_profile: availability.artist_profile
    )
    Turbo::StreamsChannel.broadcast_refresh_to(conversation) if conversation

    Turbo::StreamsChannel.broadcast_refresh_to("notifications_#{client_id}")
    Turbo::StreamsChannel.broadcast_refresh_to("notifications_#{availability.artist_profile.user_id}")
  end

  def max_active_bookings_per_artist
    return unless client && availability&.artist_profile

    exists = Booking.joins(:availability)
      .where.not(status: [ :cancelled, :completed ])
      .where(client: client, availabilities: { artist_profile_id: availability.artist_profile_id })
      .exists?

    if exists
      errors.add(:base, "You can only have 1 ongoing booking with this artist.")
    end
  end
end
