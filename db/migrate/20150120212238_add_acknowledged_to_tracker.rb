class AddAcknowledgedToTracker < ActiveRecord::Migration
  def change
  	add_column :message_trackers, :acknowledged, :boolean, default: false
  end
end
