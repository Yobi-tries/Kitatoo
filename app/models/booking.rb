class Booking < ApplicationRecord
  belongs_to :availability
  belongs_to :client, class_name: "User"

  enum :status, { selected: 0, confirmed: 1 }
end
