class Booking < ApplicationRecord
  belongs_to :availability
  belongs_to :client, class_name: "User"

  validates :availability_id, uniqueness: { message: "has already been booked" }
  validates :description, presence: true

  enum :status, { selected: 0, artist_confirmed: 1, confirmed: 2 }
end
