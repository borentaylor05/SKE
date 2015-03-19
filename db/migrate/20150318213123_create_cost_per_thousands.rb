class CreateCostPerThousands < ActiveRecord::Migration
  def change
    create_table :cost_per_thousands do |t|
      t.string :publications
      t.integer :cost

      t.timestamps null: false
    end
  end
end
