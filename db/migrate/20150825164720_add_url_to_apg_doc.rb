class AddUrlToApgDoc < ActiveRecord::Migration
  def change
  	add_column :cdc_apg_documents, :url, :string
  end
end
