class AddUsedToCode < ActiveRecord::Migration
  def change
  	add_column :ww_codes, :used, :boolean
  end
end
