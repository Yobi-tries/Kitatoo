class Address < ApplicationRecord
  belongs_to :artist_profile
  has_many :availabilities, dependent: :destroy
end
