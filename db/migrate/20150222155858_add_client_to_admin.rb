class AddClientToAdmin < ActiveRecord::Migration
  def change
  	add_column :admins, :client_name, :string
  end
end
