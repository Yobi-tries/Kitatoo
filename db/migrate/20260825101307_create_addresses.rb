# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :artist_profile, null: false, foreign_key: true
      t.string :label
      t.string :street, null: false
      t.string :zipcode, null: false
      t.string :city, null: false
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
