class CreateArcCityStates < ActiveRecord::Migration
  def change
    create_table :arc_city_states do |t|
      t.string :city
      t.string :state

      t.timestamps null: false
    end
  end
end
