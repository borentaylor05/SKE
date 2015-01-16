class AddTypeToWwInfo < ActiveRecord::Migration
  def change
  	add_column :ww_code_infos, :requesting_type, :string
  end
end
