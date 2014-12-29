class ChangeUserIdToCreatedBy < ActiveRecord::Migration
  def change
  	rename_column :issues, :user_id, :created_by
  end
end
