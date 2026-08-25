# frozen_string_literal: true

class CreateArtistProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :artist_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :display_name, null: false
      t.text :bio
      t.string :styles
      t.string :professional_status
      t.text :pricing_grid
      t.text :social_links
      t.boolean :published, null: false, default: false

      t.timestamps
    end
  end
end
