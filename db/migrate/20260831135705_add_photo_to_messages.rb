class AddPhotoToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :photo_url, :string
    add_column :messages, :photo_public_id, :string
  end
end
