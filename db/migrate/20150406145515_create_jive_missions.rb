class CreateJiveMissions < ActiveRecord::Migration
  def change
    create_table :jive_missions do |t|

      t.timestamps null: false
    end
  end
end
