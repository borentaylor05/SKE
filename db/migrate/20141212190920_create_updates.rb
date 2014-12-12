class CreateUpdates < ActiveRecord::Migration
  def change
    create_table :updates do |t|
      t.string :text
      t.integer :user_id
      t.integer :client_id
      t.string :title

      t.timestamps null: false
    end
  end
end
