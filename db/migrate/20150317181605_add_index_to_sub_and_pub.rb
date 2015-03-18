class AddIndexToSubAndPub < ActiveRecord::Migration
  def change
  	add_index :fx_publications, :name
  end
end
