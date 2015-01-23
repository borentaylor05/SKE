class RemoveMessageColumns < ActiveRecord::Migration
  def change
  	remove_column :messages, :recipient_id
  	remove_column :messages, :sender_id
  end
end
