class AddUserIdToMaintainer < ActiveRecord::Migration
  def change
  	add_column :maintainers, :user_id, :integer
  end
end
