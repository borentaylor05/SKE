class AddFieldsToAr < ActiveRecord::Migration
  def change
  	add_column :article_requests, :lob, :string
  	add_column :article_requests, :pub_date, :datetime
  	add_column :article_requests, :expire_date, :datetime
  end
end
