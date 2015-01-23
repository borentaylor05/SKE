class AddIndexToMtUserId < ActiveRecord::Migration
  def change
  	add_index :message_trackers, :user_id
  end
end
