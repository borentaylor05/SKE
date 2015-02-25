class AddJiveIdToHyundaiUsers < ActiveRecord::Migration
  def change
  	add_column :hyundai_users, :jive_id, :integer
  end
end
