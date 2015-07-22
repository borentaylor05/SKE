class AddDocIdToSection < ActiveRecord::Migration
  def change
  	add_column :cdc_apg_sections, :cdc_apg_document_id, :integer
  end
end
