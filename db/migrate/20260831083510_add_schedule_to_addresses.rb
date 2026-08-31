class AddScheduleToAddresses < ActiveRecord::Migration[8.1]
  def up
    add_column :addresses, :schedule, :text

    # Backfill: an artist who already had a global ArtistProfile#schedule keeps
    # working availability immediately, on their first/primary address, without
    # losing or overwriting any schedule already set on an address.
    execute <<~SQL.squish
      UPDATE addresses
      SET schedule = artist_profiles.schedule
      FROM artist_profiles
      WHERE addresses.artist_profile_id = artist_profiles.id
        AND artist_profiles.schedule IS NOT NULL
        AND artist_profiles.schedule <> ''
        AND (addresses.schedule IS NULL OR addresses.schedule = '')
        AND addresses.id = (
          SELECT id FROM addresses AS a2
          WHERE a2.artist_profile_id = artist_profiles.id
          ORDER BY a2.id ASC
          LIMIT 1
        )
    SQL
  end

  def down
    remove_column :addresses, :schedule
  end
end
