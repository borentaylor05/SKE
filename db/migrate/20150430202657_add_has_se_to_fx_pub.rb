class AddHasSeToFxPub < ActiveRecord::Migration
  def change
  	add_column :fx_publications, :has_se, :boolean
  end
end
