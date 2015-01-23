class AddBoolColumns < ActiveRecord::Migration
  def change
  	add_column :a_to_z_entries, :PR_bool, :boolean
  	add_column :a_to_z_entries, :Spanish_bool, :boolean
  end
end
