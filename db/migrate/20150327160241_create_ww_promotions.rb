class CreateWwPromotions < ActiveRecord::Migration
  def change
    create_table :ww_promotions do |t|
      t.string :member_num
      t.string :first_name
      t.string :last_name
      t.string :gender
      t.string :billing
      t.string :city
      t.string :state
      t.integer :zip
      t.string :agent_name

      t.timestamps null: false
    end
  end
end
