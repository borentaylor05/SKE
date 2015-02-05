class AddCatBack < ActiveRecord::Migration
  def change
  	add_column :fx_classifications, :category, :string
  end
end
