class AddInvalidToWwPromos < ActiveRecord::Migration
  def change
  	add_column :ww_promotions, :invalid, :boolean
  end
end
