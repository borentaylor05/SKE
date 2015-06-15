class RemoveCityIdFromBo < ActiveRecord::Migration
  def change
  	remove_column :arc_blackout_dates, :arc_city_state_id
  end
end
