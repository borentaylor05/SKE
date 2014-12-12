class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :jive_id
      t.string :employee_id
      t.integer :client_id

      t.timestamps null: false
    end
  end
end
