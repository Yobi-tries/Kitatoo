class AddScheduleToArtistProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :artist_profiles, :schedule, :text
  end
end
