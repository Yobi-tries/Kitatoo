class Availability < ApplicationRecord
  belongs_to :artist_profile
  belongs_to :address
  has_one :booking, dependent: :destroy

  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validate :ends_after_starts
  validate :no_overlap_for_artist, if: -> { artist_profile_id && starts_at && ends_at }

  enum :state, { open: 0, booked: 1 }

  def self.ranges_overlap?(start_a, end_a, start_b, end_b)
    start_a < end_b && end_a > start_b
  end

  def self.next_available_slot(artist_profile:, starts_at:, ends_at:, schedule: artist_profile.schedule)
    return nil if schedule.blank?

    date = starts_at.to_date
    return nil unless CalendarHelper.available_day?(schedule, date)

    day_config = schedule.dig("days", date.strftime("%A").downcase)
    return nil unless day_config

    duration = ends_at - starts_at
    day_end = Time.zone.parse("#{date} #{day_config['end']}")

    candidate_start = starts_at + 15.minutes
    while candidate_start + duration <= day_end
      candidate_end = candidate_start + duration

      conflict = artist_profile.availabilities
                               .where("starts_at < ? AND ends_at > ?", candidate_end, candidate_start)
                               .exists?

      return { starts_at: candidate_start, ends_at: candidate_end } unless conflict

      candidate_start += 15.minutes
    end

    nil
  end

  private

  def ends_after_starts
    return unless starts_at && ends_at

    errors.add(:ends_at, "must be after the start time") if ends_at <= starts_at
  end

  def no_overlap_for_artist
    conflict = artist_profile.availabilities
                             .where.not(id: id)
                             .where("starts_at < ? AND ends_at > ?", ends_at, starts_at)
                             .exists?
    errors.add(:base, "overlaps with an existing availability for this artist") if conflict
  end
end
