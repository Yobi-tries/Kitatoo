class Availability < ApplicationRecord
  belongs_to :artist_profile
  belongs_to :address
  has_one :booking, dependent: :destroy

  validates :starts_at, presence: true
  validates :ends_at, presence: true

  enum :state, { open: 0, booked: 1 }
end
