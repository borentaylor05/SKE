class AddExpiresToBo < ActiveRecord::Migration
  def change
  	add_column :arc_blackout_dates, :expires, :date
  	add_column :arc_blackout_dates, :expires_yellow, :date
  end
end
