# frozen_string_literal: true

class CreateAvailabilities < ActiveRecord::Migration[8.1]
  def change
    create_table :availabilities do |t|
      t.references :artist_profile, null: false, foreign_key: true
      t.references :address, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :state, null: false, default: 0

      t.timestamps
    end

    add_index :availabilities, :starts_at
  end
end
