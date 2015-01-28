class CreateDeadlines < ActiveRecord::Migration
  def change
    create_table :deadlines do |t|
      t.string :publication
      t.string :nz_time
      t.string :mla_time
      t.string :run_day
      t.string :close_day

      t.timestamps null: false
    end
  end
end
