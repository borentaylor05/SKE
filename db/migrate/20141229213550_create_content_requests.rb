class CreateContentRequests < ActiveRecord::Migration
  def change
    create_table :content_requests do |t|
      t.string :request_type
      t.integer :content_id
      t.string :title
      t.string :description

      t.timestamps null: false
    end
  end
end
