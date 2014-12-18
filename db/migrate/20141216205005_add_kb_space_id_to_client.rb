class AddKbSpaceIdToClient < ActiveRecord::Migration
  def change
  	add_column :clients, :kb_space_id, :integer
  end
end
