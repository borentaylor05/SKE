class AddDefaultToUsed < ActiveRecord::Migration
  def change
  	change_column :ww_codes, :used, :boolean, :default => false
  end
end
