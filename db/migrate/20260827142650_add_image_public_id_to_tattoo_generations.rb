class AddImagePublicIdToTattooGenerations < ActiveRecord::Migration[8.1]
  def change
    add_column :tattoo_generations, :image_public_id, :string
  end
end
