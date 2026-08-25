# frozen_string_literal: true

class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.references :client, null: false, foreign_key: { to_table: :users }
      t.references :artist_profile, null: false, foreign_key: true

      t.timestamps
    end

    add_index :conversations, [ :client_id, :artist_profile_id ],
              unique: true, name: "index_conversations_on_client_and_artist"
  end
end
