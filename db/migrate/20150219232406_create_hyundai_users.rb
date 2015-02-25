class CreateHyundaiUsers < ActiveRecord::Migration
  def change
    create_table :hyundai_users do |t|
      t.string :name
      t.integer :oracle_id
      t.string :lob
      t.string :location
      t.string :title

      t.timestamps null: false
    end
  end
end
