class CreateWwOprahCodes < ActiveRecord::Migration
  def change
    create_table :ww_oprah_codes do |t|
      t.string :code
      t.boolean :used, default: false

      t.timestamps null: false
    end
  end
end
