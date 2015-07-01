class AddCaseToArcct < ActiveRecord::Migration
  def change
  	add_column :arc_check_trackers, :case, :integer	
  end
end
