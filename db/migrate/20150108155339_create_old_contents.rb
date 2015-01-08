class CreateOldContents < ActiveRecord::Migration
  def change
    create_table :old_contents do |t|
      t.integer :api_id
      t.integer :comments

      t.timestamps null: false
    end
  end
end
