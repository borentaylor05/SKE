class AddIndexToJiveId < ActiveRecord::Migration
  def change
  	add_index :users, :jive_id
  end
end
