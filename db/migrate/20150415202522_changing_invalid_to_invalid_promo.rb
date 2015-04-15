class ChangingInvalidToInvalidPromo < ActiveRecord::Migration
  def change
  	rename_column :ww_promotions, :invalid, :invalid_promo
  end
end
