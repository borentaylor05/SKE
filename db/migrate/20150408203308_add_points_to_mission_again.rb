class AddPointsToMissionAgain < ActiveRecord::Migration
  def change
  	add_column :missions, :points, :integer
  end
end
