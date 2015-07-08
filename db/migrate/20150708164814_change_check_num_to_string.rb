class ChangeCheckNumToString < ActiveRecord::Migration
  def change
  	change_column :arc_check_trackers, :check_num, :string
  	add_index :arc_check_trackers, :check_num
  end
end
