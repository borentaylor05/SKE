class CreateMaintainers < ActiveRecord::Migration
  def change
    create_table :maintainers do |t|
      t.boolean :pcf
      t.integer :assigned_to
      t.text :response
      t.string :result
      t.string :ticket_type
      t.integer :ticket_id

      t.timestamps null: false
    end
  end
end
