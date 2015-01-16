class AddDescToCodeInfo < ActiveRecord::Migration
  def change
  	add_column :ww_code_infos, :description, :text
  end
end
