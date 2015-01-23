class RemoveStringColumns < ActiveRecord::Migration
  def change
  	remove_column :a_to_z_entries, :PRs
  	remove_column :a_to_z_entries, :Spanish
  end
end
