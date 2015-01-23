class CreateMessageTrackers < ActiveRecord::Migration
  def change
    create_table :message_trackers do |t|
      t.integer :user_id
      t.integer :message_id

      t.timestamps null: false
    end
  end
end
