class Availability < ApplicationRecord
  belongs_to :artist_profile
  belongs_to :address
  has_one :booking, dependent: :destroy

  enum :state, { open: 0, booked: 1 }
end
