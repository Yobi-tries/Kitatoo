class AddAvatarToArtistProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :artist_profiles, :avatar_url, :string
    add_column :artist_profiles, :avatar_public_id, :string
  end
end
