class AddIndexToSuburbName < ActiveRecord::Migration
  def change
  	add_index :suburbs, :name
  end
end
