class AddCodeToOprahTracker < ActiveRecord::Migration
  def change
    add_column :ww_oprah_trackers, :code_used, :string
  end
end
