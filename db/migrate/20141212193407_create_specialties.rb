class CreateSpecialties < ActiveRecord::Migration
  def change
    create_table :specialties do |t|
      t.string :name
      t.integer :client_id

      t.timestamps null: false
    end
  end
end
