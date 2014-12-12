class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.integer :api_id
      t.string :doc_id
      t.string :title
      t.integer :user_id
      t.integer :client_id
      t.boolean :featured
      t.string :message

      t.timestamps null: false
    end
  end
end
