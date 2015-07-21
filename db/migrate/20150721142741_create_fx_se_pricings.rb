class CreateFxSePricings < ActiveRecord::Migration
  def change
    create_table :fx_se_pricings do |t|
      t.integer :fx_publication_id
      t.decimal :nz_delivery
      t.decimal :au_delivery
      t.decimal :row_delivery
      t.decimal :subscribers
      t.decimal :standard

      t.timestamps null: false
    end
  end
end
