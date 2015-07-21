class CreateCdcApgSections < ActiveRecord::Migration
  def change
    create_table :cdc_apg_sections do |t|
      t.string :title

      t.timestamps null: false
    end
  end
end
