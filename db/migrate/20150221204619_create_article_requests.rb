class CreateArticleRequests < ActiveRecord::Migration
  def change
    create_table :article_requests do |t|
      t.string :title
      t.text :summary
      t.string :file_label
      t.string :file_url

      t.timestamps null: false
    end
  end
end
