class AddBodyImageToBodyPreviews < ActiveRecord::Migration[8.1]
  def change
    add_column :body_previews, :body_image_url, :string
    add_column :body_previews, :body_image_public_id, :string
  end
end
