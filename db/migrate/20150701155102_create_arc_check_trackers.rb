class CreateArcCheckTrackers < ActiveRecord::Migration
  def change
    create_table :arc_check_trackers do |t|
      t.integer :check_num
      t.decimal :check_amount
      t.string :check_date
      t.string :org
      t.string :check_name
      t.string :state
      t.string :tsc_received
      t.string :order_num
      t.string :crs
      t.string :notes
      t.string :sent_back_by
      t.string :agent_name

      t.timestamps null: false
    end
  end
end
