class AddFieldsToUser < ActiveRecord::Migration
  def change
  	add_column :users, :title, :string
  	add_column :users, :location, :string
  	add_column :users, :lob, :string
  end
end
