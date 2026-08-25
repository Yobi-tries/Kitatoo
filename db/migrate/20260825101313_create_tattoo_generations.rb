# frozen_string_literal: true

class CreateTattooGenerations < ActiveRecord::Migration[8.1]
  def change
    create_table :tattoo_generations do |t|
      t.references :user, null: false, foreign_key: true
      t.text :prompt, null: false
      t.string :image_url

      t.timestamps
    end
  end
end
