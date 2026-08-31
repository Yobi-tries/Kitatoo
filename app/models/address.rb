class Address < ApplicationRecord
  belongs_to :artist_profile

  serialize :schedule, coder: JSON

  geocoded_by :full_address
  after_validation :geocode, if: -> { will_save_change_to_street? || will_save_change_to_zipcode? || will_save_change_to_city? }

  validates :street, presence: true
  validates :zipcode, presence: true
  validates :city, presence: true

  has_many :availabilities, dependent: :destroy

  def full_address
    "#{street}, #{zipcode} #{city}"
  end
end
