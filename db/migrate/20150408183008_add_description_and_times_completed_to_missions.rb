class AddDescriptionAndTimesCompletedToMissions < ActiveRecord::Migration
  def change
  	add_column :missions, :description, :string
  	add_column :user_missions, :times_completed, :integer
  	add_column :user_missions, :progress, :integer
  	add_column :user_missions, :notify_complete, :boolean
  end
end
