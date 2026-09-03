class AddViewedAtToTattooGenerationsAndBodyPreviews < ActiveRecord::Migration[8.1]
  def change
    add_column :tattoo_generations, :viewed_at, :datetime
    add_column :body_previews, :viewed_at, :datetime

    reversible do |dir|
      dir.up do
        # Completed results that already exist predate this feature -- back-fill
        # viewed_at so they don't retroactively light up the new badge.
        execute "UPDATE tattoo_generations SET viewed_at = updated_at WHERE status = 1"
        execute "UPDATE body_previews SET viewed_at = updated_at WHERE status = 1"
      end
    end
  end
end
