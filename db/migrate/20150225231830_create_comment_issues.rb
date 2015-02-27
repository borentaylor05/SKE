class CreateCommentIssues < ActiveRecord::Migration
  def change
    create_table :comment_issues do |t|
      t.integer :user_id
      t.integer :old_comment_id

      t.timestamps null: false
    end
  end
end
