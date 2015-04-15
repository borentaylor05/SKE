class AddSignupDateToWwPromos < ActiveRecord::Migration
  def change
  	add_column :ww_promotions, :signup_date, :date
  end
end
