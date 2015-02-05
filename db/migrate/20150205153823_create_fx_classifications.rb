class CreateFxClassifications < ActiveRecord::Migration
  def change
    create_table :fx_classifications do |t|
      t.string :title
      t.string :code
      t.string :category

      t.timestamps null: false
    end
  end
end
