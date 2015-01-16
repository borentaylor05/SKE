class CreateWwCodeInfos < ActiveRecord::Migration
  def change
    create_table :ww_code_infos do |t|
      t.string :agent_id
      t.string :agent_name
      t.integer :sub_num
      t.string :member_first_name
      t.string :member_last_name
      t.integer :member_zip
      t.integer :ww_code_id

      t.timestamps null: false
    end
  end
end
