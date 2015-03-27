class AddIndexToWwMemberId < ActiveRecord::Migration
  def change
  	add_index :ww_promotions, :member_num
  end
end
