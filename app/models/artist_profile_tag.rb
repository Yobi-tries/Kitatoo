class ArtistProfileTag < ApplicationRecord
  belongs_to :artist_profile
  belongs_to :tag

  validates :tag_id, uniqueness: { scope: :artist_profile_id }
end
