class AddMagToFxPub < ActiveRecord::Migration
  def change
  	add_column :fx_publications, :mag, :boolean
  end
end
