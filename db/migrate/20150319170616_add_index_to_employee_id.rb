class AddIndexToEmployeeId < ActiveRecord::Migration
  def change
  	add_index :users, :employee_id
  end
end
