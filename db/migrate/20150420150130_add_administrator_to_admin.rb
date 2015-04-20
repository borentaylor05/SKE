class AddAdministratorToAdmin < ActiveRecord::Migration
  def change
  	add_column :admins, :administrator, :boolean, default: false
  end
end
