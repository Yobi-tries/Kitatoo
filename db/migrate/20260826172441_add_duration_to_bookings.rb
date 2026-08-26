class AddDurationToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :duration, :integer
  end
end
