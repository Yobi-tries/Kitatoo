class ArtistProfile < ApplicationRecord
  belongs_to :user
  has_many :addresses, dependent: :destroy
  has_many :availabilities, dependent: :destroy
  has_many :portfolio_items, dependent: :destroy
  has_many :conversations, dependent: :destroy
end
