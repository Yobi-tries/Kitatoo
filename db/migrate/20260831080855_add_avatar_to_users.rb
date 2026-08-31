class AddAvatarToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :avatar_url, :string
    add_column :users, :avatar_public_id, :string
  end
end
