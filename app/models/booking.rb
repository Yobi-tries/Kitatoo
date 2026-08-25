class Booking < ApplicationRecord
  belongs_to :availability
  belongs_to :client, class_name: "User"

  validates :availability_id, uniqueness: true

  enum :status, { selected: 0, confirmed: 1 }
end
