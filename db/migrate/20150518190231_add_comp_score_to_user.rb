class AddCompScoreToUser < ActiveRecord::Migration
  def change
  	add_column :users, :comp_score, :string
  end
end
