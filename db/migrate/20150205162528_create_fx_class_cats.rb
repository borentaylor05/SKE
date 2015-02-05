class CreateFxClassCats < ActiveRecord::Migration
  def change
    create_table :fx_class_cats do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
