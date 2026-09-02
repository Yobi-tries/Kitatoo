class MakePlacementOptionalOnBodyPreviews < ActiveRecord::Migration[8.1]
  def change
    change_column_null :body_previews, :placement, true
  end
end
