class CreateMissions < ActiveRecord::Migration
  def change
    create_table :missions do |t|
      t.string :bunchball_name
      t.string :badge_url
      t.string :game_type
      t.integer :game_id
      t.string :folder

      t.timestamps null: false
    end
  end
end
