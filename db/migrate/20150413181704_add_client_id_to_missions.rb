class AddClientIdToMissions < ActiveRecord::Migration
  def change
  	add_column :missions, :client_id, :integer
  end
end
