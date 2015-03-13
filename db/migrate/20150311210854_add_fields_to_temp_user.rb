class AddFieldsToTempUser < ActiveRecord::Migration
  def change
  	rename_column :temp_users, :username, :oracle_id
  	add_column :temp_users, :job_title, :string
  	add_column :temp_users, :client, :string
  	add_column :temp_users, :region, :string
  	add_column :temp_users, :location, :string
  	add_column :temp_users, :lob, :string
  	add_column :users, :region, :string
  end
end
