class AddPubIdToMagPricing < ActiveRecord::Migration
  def change
  	add_column :fx_mag_pricings, :fx_publication_id, :integer
  end
end
