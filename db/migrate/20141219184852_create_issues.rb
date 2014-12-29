class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.string :summary
      t.integer :user_id
      t.integer :content_id

      t.timestamps null: false
    end
  end
end
