class AddFxClassCatId < ActiveRecord::Migration
  def change
  	add_column :fx_classifications, :fx_class_cat_id, :integer
  end
end
