class AddIndexesToCodes < ActiveRecord::Migration
  def change
  	add_index :ww_codes, :code_num
  	add_index :ww_codes, :assigned_by_name
  	add_index :ww_code_infos, :agent_name
  end
end
