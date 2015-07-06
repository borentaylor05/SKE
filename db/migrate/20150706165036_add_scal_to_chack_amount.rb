class AddScalToChackAmount < ActiveRecord::Migration
  def change
  	change_column :arc_check_trackers, :check_amount, :decimal, precision: 10, scale: 2
  end
end
