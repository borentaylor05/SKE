class AddDoDeleteToMaintainer < ActiveRecord::Migration
  def change
  	add_column :maintainers, :do_delete, :boolean, default: false
  end
end
