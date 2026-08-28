class ReplaceUniqueIndexOnBookingsAvailabilityId < ActiveRecord::Migration[8.1]
  def up
    remove_index :bookings, :availability_id
    add_index :bookings, :availability_id
  end

  def down
    remove_index :bookings, :availability_id
    add_index :bookings, :availability_id, unique: true
  end
end
