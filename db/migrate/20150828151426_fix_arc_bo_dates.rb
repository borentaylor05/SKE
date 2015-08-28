class FixArcBoDates < ActiveRecord::Migration
  def change
  	remove_column :arc_blackout_dates, :expires_yellow, :date
	add_column :arc_blackout_dates, :date_type, :string
  end
end
