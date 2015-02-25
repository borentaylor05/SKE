class RemoveClientFromAdmin < ActiveRecord::Migration
  def change
  	remove_column :admins, :client_name
  end
end
