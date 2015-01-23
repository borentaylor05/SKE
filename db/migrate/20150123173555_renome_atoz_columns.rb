class RenomeAtozColumns < ActiveRecord::Migration
  def change
  	rename_column :a_to_z_entries, :Topic, :topic 
  	rename_column :a_to_z_entries, :AKA, :aka 
  	rename_column :a_to_z_entries, :Owner, :owner
  	rename_column :a_to_z_entries, :Scope, :scope
  	rename_column :a_to_z_entries, :Notes, :notes   
  	rename_column :a_to_z_entries, :ProgramFlow, :program_flow
  	rename_column :a_to_z_entries, :CDC_link, :cdc_link
  	rename_column :a_to_z_entries, :PR_bool, :pr   
  	rename_column :a_to_z_entries, :Spanish_bool, :spanish 
  end
end
