class AddAdditionalAttachmentsToRequest < ActiveRecord::Migration
  def change
  	add_column :article_requests, :file_label2, :string
  	add_column :article_requests, :file_label3, :string
  	add_column :article_requests, :file_url2, :string
  	add_column :article_requests, :file_url3, :string
  end
end
