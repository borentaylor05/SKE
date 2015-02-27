class AddUsernameToTempUser < ActiveRecord::Migration
  def change
  	add_column :temp_users, :username, :string
  end
end
