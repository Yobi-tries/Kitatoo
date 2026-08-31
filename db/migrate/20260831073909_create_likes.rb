class CreateLikes < ActiveRecord::Migration[8.1]
  def change
    create_table :likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :artist_profile, null: false, foreign_key: true

      t.timestamps

      t.index [:user_id, :artist_profile_id], unique: true
    end
  end
end
