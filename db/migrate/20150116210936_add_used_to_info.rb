class AddUsedToInfo < ActiveRecord::Migration
  def change
  	add_column :ww_code_infos, :used, :boolean, default: false
  	add_column :ww_code_infos, :reviewed_by, :string
  end
end
