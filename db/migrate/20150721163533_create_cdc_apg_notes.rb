class CreateCdcApgNotes < ActiveRecord::Migration
  def change
    create_table :cdc_apg_notes do |t|
      t.integer :cdc_apg_subheader_id
      t.text :text

      t.timestamps null: false
    end
  end
end
