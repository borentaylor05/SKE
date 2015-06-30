class RepurposeFxMagPricing < ActiveRecord::Migration
  def change
  	add_column :fx_mag_pricings, :pay_type, :string
  	add_column :fx_mag_pricings, :one_year, :decimal
  	add_column :fx_mag_pricings, :one_year_aus, :decimal
  	add_column :fx_mag_pricings, :one_year_row, :decimal
  	add_column :fx_mag_pricings, :two_years, :decimal
  	add_column :fx_mag_pricings, :three_years, :decimal
  	add_column :fx_mag_pricings, :bank, :decimal
  	add_column :fx_mag_pricings, :credit, :decimal

  	remove_column :fx_mag_pricings, :one_year_supergold
  	remove_column :fx_mag_pricings, :one_year_new
  	remove_column :fx_mag_pricings, :one_year_renewal
  	remove_column :fx_mag_pricings, :two_year_renewal
  	remove_column :fx_mag_pricings, :two_year_new
  	remove_column :fx_mag_pricings, :three_year_renewal
  	remove_column :fx_mag_pricings, :three_year_new
  end
end
