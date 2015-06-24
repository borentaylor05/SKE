class AddForeignKeyToFxcr < ActiveRecord::Migration
  def change
  	add_column :fx_code_rates, :fx_publication_id, :integer
  end
end
