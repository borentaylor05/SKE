class AddClientToAdmin2 < ActiveRecord::Migration
  def change
  	add_column :admins, :client_id, :integer
  end
end
