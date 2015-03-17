class CreateFxPublications < ActiveRecord::Migration
  def change
    create_table :fx_publications do |t|
      t.string :name
      t.string :parent

      t.timestamps null: false
    end
  end
end
