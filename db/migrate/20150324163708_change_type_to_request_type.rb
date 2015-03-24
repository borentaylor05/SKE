class ChangeTypeToRequestType < ActiveRecord::Migration
  def change
  	rename_column :article_requests, :type, :request_type
  end
end
