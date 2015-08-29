class CreateArcCityStateGroups < ActiveRecord::Migration
  def change
    create_table :arc_city_state_groups do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
