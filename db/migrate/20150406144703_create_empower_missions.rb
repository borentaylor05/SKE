class CreateEmpowerMissions < ActiveRecord::Migration
  def change
    create_table :empower_missions do |t|
      t.string :metric_name
      t.string :target

      t.timestamps null: false
    end
  end
end
