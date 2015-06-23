class RepurposePromoForm < ActiveRecord::Migration
  def change
  	add_column :ww_promotions, :member_phone, :string
  	add_column :ww_promotions, :description, :text
  	add_column :ww_promotions, :meet_city, :string
  	add_column :ww_promotions, :meet_state, :string

  	remove_column :ww_promotions, :gender
  	remove_column :ww_promotions, :signup_date
  	remove_column :ww_promotions, :invalid_promo
  	remove_column :ww_promotions, :nonqual
  end
end
