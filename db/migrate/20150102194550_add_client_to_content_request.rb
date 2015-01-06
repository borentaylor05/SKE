class AddClientToContentRequest < ActiveRecord::Migration
  def change
  	add_column :content_requests, :client_id, :integer
  end
end
