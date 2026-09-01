class CreateBodyPreviews < ActiveRecord::Migration[8.1]
  def change
    create_table :body_previews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :tattoo_generation, foreign_key: true
      t.string :placement, null: false
      t.string :source_image_url, null: false
      t.string :source_image_public_id
      t.string :preview_image_url
      t.string :preview_image_public_id
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
