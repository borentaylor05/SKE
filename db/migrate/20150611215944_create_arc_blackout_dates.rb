class CreateArcBlackoutDates < ActiveRecord::Migration
  def change
    create_table :arc_blackout_dates do |t|
      t.string :date
      t.string :notes

      t.timestamps null: false
    end
  end
end
