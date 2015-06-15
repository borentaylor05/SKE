class CreateArcBlackoutTrackers < ActiveRecord::Migration
  def change
    create_table :arc_blackout_trackers do |t|
      t.integer :arc_blackout_date_id
      t.integer :arc_city_state_id

      t.timestamps null: false
    end
  end
end
