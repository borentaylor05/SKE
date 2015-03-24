class AddRedeliveryIndexes < ActiveRecord::Migration
  def change
  	add_index :redeliveries, :round_id
  	add_index :redeliveries, :town
  end
end
