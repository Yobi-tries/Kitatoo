# frozen_string_literal: true

class CreatePortfolioItems < ActiveRecord::Migration[8.1]
  def change
    create_table :portfolio_items do |t|
      t.references :artist_profile, null: false, foreign_key: true
      t.string :image_url, null: false
      t.string :caption
      t.integer :position

      t.timestamps
    end
  end
end
