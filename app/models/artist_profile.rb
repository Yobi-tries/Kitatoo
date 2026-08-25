class ArtistProfile < ApplicationRecord
  belongs_to :user

  validates :user_id, uniqueness: true
  validates :display_name, presence: true

  has_many :addresses, dependent: :destroy
  has_many :availabilities, dependent: :destroy
  has_many :portfolio_items, dependent: :destroy
  has_many :conversations, dependent: :destroy
end
