class CreateSfOAuths < ActiveRecord::Migration
  def change
    create_table :sf_o_auths do |t|
      t.string :token
      t.string :refresh_token
      t.string :instance_url
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
