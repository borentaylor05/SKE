class AddNonqualToWwPromos < ActiveRecord::Migration
  def change
  	add_column :ww_promotions, :nonqual, :boolean
  end
end
