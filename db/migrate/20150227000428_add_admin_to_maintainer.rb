class AddAdminToMaintainer < ActiveRecord::Migration
  def change
  	add_column :maintainers, :admin_id, :integer
  end
end
