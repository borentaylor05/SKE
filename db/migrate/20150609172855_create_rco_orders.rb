class CreateRcoOrders < ActiveRecord::Migration
  def change
    create_table :rco_orders do |t|
      t.string :agent_name
      t.boolean :created
      t.boolean :acct_with_password
      t.boolean :acct_forgot_password
      t.boolean :no_share
      t.string :order_id
      t.integer :lms_num
      t.integer :num_registrations
      t.string :coupon
      t.boolean :paypal
      t.boolean :knows_lms
      t.boolean :need_dir
      t.boolean :attch_sent
      t.text :comments

      t.timestamps null: false
    end
  end
end
