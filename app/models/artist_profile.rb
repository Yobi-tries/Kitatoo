class ArtistProfile < ApplicationRecord
  belongs_to :user

  serialize :pricing_grid, coder: JSON

  validates :user_id, uniqueness: true
  validates :display_name, presence: true

  has_many :addresses, dependent: :destroy
  has_many :availabilities, dependent: :destroy
  has_many :portfolio_items, dependent: :destroy
  has_many :conversations, dependent: :destroy
  has_many :artist_profile_tags, dependent: :destroy
  has_many :tags, through: :artist_profile_tags
end
