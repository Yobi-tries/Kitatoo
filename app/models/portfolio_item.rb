class PortfolioItem < ApplicationRecord
  belongs_to :artist_profile

  validates :image_url, presence: true
end
