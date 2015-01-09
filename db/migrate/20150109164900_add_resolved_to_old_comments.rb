class AddResolvedToOldComments < ActiveRecord::Migration
  def change
  	add_column :old_comments, :resolved, :boolean
  	add_column :old_comments, :resolved_at, :datetime
  end
end
