class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :text
      t.integer :client_id
      t.integer :group_id
      t.integer :sender_id
      t.integer :recipient_id

      t.timestamps null: false
    end
  end
end
