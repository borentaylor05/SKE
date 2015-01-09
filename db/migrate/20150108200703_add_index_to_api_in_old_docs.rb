class AddIndexToApiInOldDocs < ActiveRecord::Migration
  def change
  	add_index :old_contents, :api_id
  end
end
