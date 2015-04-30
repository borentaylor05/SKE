class CreateFxMagPricings < ActiveRecord::Migration
  def change
    create_table :fx_mag_pricings do |t|
      t.string :six_month
      t.string :one_year_renewal
      t.string :one_year_new
      t.string :two_year_new
      t.string :two_year_renewal
      t.string :one_year_supergold
      t.string :three_year_new
      t.string :three_year_renewal

      t.timestamps null: false
    end
  end
end
