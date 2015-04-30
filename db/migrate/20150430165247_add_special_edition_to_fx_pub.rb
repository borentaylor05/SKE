class AddSpecialEditionToFxPub < ActiveRecord::Migration
  def change
  	add_column :fx_publications, :se, :boolean
  end
end
