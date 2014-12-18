class AddIndexToSpecialtyName < ActiveRecord::Migration
  def change
  	add_index :specialties, :name
  end
end
