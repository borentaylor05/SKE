class AddTokenToWwInfo < ActiveRecord::Migration
  def change
  	add_column :ww_code_infos, :token, :string
  	add_index :ww_code_infos, :token, unique: true 
  end
end
