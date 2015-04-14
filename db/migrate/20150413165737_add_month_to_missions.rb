class AddMonthToMissions < ActiveRecord::Migration
  def change
  	add_column :missions, :month, :string
  end
end
