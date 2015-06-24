class CreateFxCodeRates < ActiveRecord::Migration
  def change
    create_table :fx_code_rates do |t|
      t.string :schedule
      t.string :month_code
      t.decimal :month_rate
      t.string :year_code
      t.decimal :year_rate
      t.string :other
      t.boolean :three_day

      t.timestamps null: false
    end
  end
end
