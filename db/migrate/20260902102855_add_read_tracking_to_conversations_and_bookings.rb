class AddReadTrackingToConversationsAndBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :conversations, :client_last_read_at, :datetime
    add_column :conversations, :artist_last_read_at, :datetime

    add_column :bookings, :client_notified_at, :datetime
    add_column :bookings, :artist_notified_at, :datetime
  end
end
