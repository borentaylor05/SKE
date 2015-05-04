class AddPriorityToMission < ActiveRecord::Migration
  def change
  	add_column :missions, :priority, :integer, default: 99
  end
end
