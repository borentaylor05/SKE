class RemoveUserIdFromCi < ActiveRecord::Migration
  def change
  	remove_column :comment_issues, :user_id
  end
end
