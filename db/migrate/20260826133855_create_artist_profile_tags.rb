# frozen_string_literal: true

class CreateArtistProfileTags < ActiveRecord::Migration[8.1]
  def change
    create_table :artist_profile_tags do |t|
      t.references :artist_profile, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :artist_profile_tags, [ :artist_profile_id, :tag_id ], unique: true
  end
end
