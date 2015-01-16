class CreateWwCodes < ActiveRecord::Migration
  def change
    create_table :ww_codes do |t|
      t.string :code_type
      t.string :code_num
      t.datetime :date_assigned
      t.string :assigned_by

      t.timestamps null: false
    end
  end
end
