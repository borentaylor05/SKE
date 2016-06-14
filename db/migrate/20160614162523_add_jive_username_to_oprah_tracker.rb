class AddJiveUsernameToOprahTracker < ActiveRecord::Migration
  def change
    add_column :ww_oprah_trackers, :jive_username, :string
  end
end
