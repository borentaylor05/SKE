class TweakArcCityTable < ActiveRecord::Migration
  def change
  	remove_column :arc_city_states, :state
  	add_column :arc_city_states, :state_id, :integer
  end
end
