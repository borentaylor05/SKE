class RemoveRcoColumns < ActiveRecord::Migration
  def change
  	remove_column :rco_orders, :knows_lms
  	remove_column :rco_orders, :attch_sent
  	remove_column :rco_orders, :need_dir
  end
end
