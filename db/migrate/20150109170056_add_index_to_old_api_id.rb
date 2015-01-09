class AddIndexToOldApiId < ActiveRecord::Migration
  def change
  	add_index :old_comments, :api_id
  end
end
