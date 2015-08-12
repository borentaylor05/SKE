class AddTlToUser < ActiveRecord::Migration
  def change
  	add_column :users, :team_lead_id, :integer
  end
end
