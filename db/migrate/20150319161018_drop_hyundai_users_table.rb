class DropHyundaiUsersTable < ActiveRecord::Migration
  def change
  	drop_table :hyundai_users
  end
end
