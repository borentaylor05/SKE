class AddResolvedToMaintainer < ActiveRecord::Migration
  def change
  	add_column :maintainers, :resolved, :boolean
  end
end
