class AddCommentsUrlToOldContent < ActiveRecord::Migration
  def change
  	add_column :old_contents, :commentsUrl, :string
  end
end
