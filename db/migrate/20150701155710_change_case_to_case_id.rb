class ChangeCaseToCaseId < ActiveRecord::Migration
  def change
  	rename_column :arc_check_trackers, :case, :case_id
  end
end
