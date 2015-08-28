class AddCityStateIdToBoDates < ActiveRecord::Migration
  def change
  	add_column :arc_blackout_dates, :arc_city_state_id, :integer
  end
end
