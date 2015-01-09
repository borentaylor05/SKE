class CreateOldComments < ActiveRecord::Migration
  def change
    create_table :old_comments do |t|
      t.integer :old_content_id
      t.integer :api_id

      t.timestamps null: false
    end
  end
end
