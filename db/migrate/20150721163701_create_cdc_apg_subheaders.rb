class CreateCdcApgSubheaders < ActiveRecord::Migration
  def change
    create_table :cdc_apg_subheaders do |t|
      t.string :title
      t.integer :cdc_apg_section_id

      t.timestamps null: false
    end
  end
end
