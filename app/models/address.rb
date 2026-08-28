class Address < ApplicationRecord
  belongs_to :artist_profile

  geocoded_by :full_address
  after_validation :geocode, if: :will_save_change_to_street?

  validates :street, presence: true
  validates :zipcode, presence: true
  validates :city, presence: true

  has_many :availabilities, dependent: :destroy

  def full_address
    "#{street}, #{zipcode} #{city}"
  end
end
