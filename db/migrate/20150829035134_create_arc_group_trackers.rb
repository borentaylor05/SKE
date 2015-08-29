class CreateArcGroupTrackers < ActiveRecord::Migration
  def change
    create_table :arc_group_trackers do |t|
      t.integer :arc_city_state_id
      t.integer :arc_city_state_group_id

      t.timestamps null: false
    end
  end
end
