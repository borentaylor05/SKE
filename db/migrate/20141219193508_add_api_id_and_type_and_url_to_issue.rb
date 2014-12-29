class AddApiIdAndTypeAndUrlToIssue < ActiveRecord::Migration
  def change
  	add_column :issues, :api_id, :integer
  	add_column :issues, :issue_type, :string
  	add_column :issues, :url, :string
  end
end
