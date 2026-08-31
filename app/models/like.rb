class Like < ApplicationRecord
  belongs_to :user
  belongs_to :artist_profile

  validates :artist_profile_id, uniqueness: { scope: :user_id }
end
