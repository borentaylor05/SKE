class RemoveCatAgain < ActiveRecord::Migration
  def change
  	remove_column :fx_classifications, :category
  end
end
