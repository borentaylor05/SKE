class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.integer :client_id
      t.string :action_type
      t.integer :action_id

      t.timestamps null: false
    end
  end
end
