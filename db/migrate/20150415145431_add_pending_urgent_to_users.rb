class AddPendingUrgentToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :pending_urgent, :boolean
  end
end
