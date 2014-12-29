class AddResolvedToIssues < ActiveRecord::Migration
  def change
  	add_column :issues, :resolved, :boolean
  	add_column :issues, :resolved_by, :integer
  	add_column :issues, :resolved_at, :datetime
  end
end
