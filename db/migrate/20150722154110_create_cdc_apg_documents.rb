class CreateCdcApgDocuments < ActiveRecord::Migration
  def change
    create_table :cdc_apg_documents do |t|
      t.integer :client_id
      t.string :title

      t.timestamps null: false
    end
  end
end
