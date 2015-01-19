class AddNameToWwCode < ActiveRecord::Migration
  def change
  	add_column :ww_codes, :assigned_by_name, :string
  end
end
