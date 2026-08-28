class AddDescriptionToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :description, :text
  end
end
