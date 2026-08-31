class ArtistProfile < ApplicationRecord
  belongs_to :user

  serialize :schedule, coder: JSON
  serialize :pricing_grid, coder: JSON
  serialize :social_links, coder: JSON

  validates :user_id, uniqueness: true
  validates :display_name, presence: true

  has_many :addresses, dependent: :destroy
  has_many :availabilities, dependent: :destroy
  has_many :portfolio_items, dependent: :destroy
  has_many :conversations, dependent: :destroy
  has_many :artist_profile_tags, dependent: :destroy
  has_many :tags, through: :artist_profile_tags

  def cover_image
    portfolio_items.find_by(position: 1)
  end

  # Shared schedule-params parser, reused by ArtistProfile (legacy) and Address
  # (current) schedule forms — same JSON shape either way.
  def self.build_schedule_from(s)
    days = {}
    %w[monday tuesday wednesday thursday friday saturday sunday].each do |day|
      if s.dig(:days, day, :enabled) == "1"
        days[day] = { "start" => s.dig(:days, day, :start), "end" => s.dig(:days, day, :end) }
      else
        days[day] = nil
      end
    end
    days_off = (s[:days_off] || {}).values.reject(&:blank?)
    {
      "slot_duration" => s[:slot_duration].to_i,
      "period_start" => s[:period_start],
      "period_end" => s[:period_end],
      "days" => days,
      "days_off" => days_off
    }
  end
end
