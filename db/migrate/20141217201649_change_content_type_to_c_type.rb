class ChangeContentTypeToCType < ActiveRecord::Migration
  def change
  	rename_column :contents, :type, :cType
  end
end
