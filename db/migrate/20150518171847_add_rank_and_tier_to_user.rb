class AddRankAndTierToUser < ActiveRecord::Migration
  def change
  	add_column :users, :rank, :integer
  	add_column :users, :tier, :integer
  end
end
