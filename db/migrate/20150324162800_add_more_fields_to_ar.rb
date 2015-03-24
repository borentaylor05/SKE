class AddMoreFieldsToAr < ActiveRecord::Migration
  def change
  	add_column :article_requests, :priority, :integer
  	add_column :article_requests, :type, :string
  end
end
