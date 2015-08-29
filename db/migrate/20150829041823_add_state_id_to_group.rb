class AddStateIdToGroup < ActiveRecord::Migration
  def change
  	add_column :arc_city_state_groups, :state_id, :integer
  end
end
