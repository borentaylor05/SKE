class AddClientIdToMaintainers < ActiveRecord::Migration
  def change
  	add_column :maintainers, :client_id, :integer
  end
end
