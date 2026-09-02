class AddReferenceImagesToTattooGenerations < ActiveRecord::Migration[8.1]
  def change
    add_column :tattoo_generations, :reference_image_urls, :text, array: true, default: [], null: false
    add_column :tattoo_generations, :reference_image_public_ids, :text, array: true, default: [], null: false
  end
end
