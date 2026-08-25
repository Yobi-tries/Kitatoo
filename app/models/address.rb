class Address < ApplicationRecord
  belongs_to :artist_profile

  validates :street, presence: true
  validates :zipcode, presence: true
  validates :city, presence: true

  has_many :availabilities, dependent: :destroy
end
