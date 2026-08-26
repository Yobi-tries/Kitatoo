# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.string :normalized_name, null: false

      t.timestamps
    end

    add_index :tags, :normalized_name, unique: true
  end
end
