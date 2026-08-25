# frozen_string_literal: true

class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :username, :string, null: false
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :birthdate, :date, null: false
    add_column :users, :city, :string
    add_column :users, :latitude, :float
    add_column :users, :longitude, :float

    add_index :users, :username, unique: true
  end
end
