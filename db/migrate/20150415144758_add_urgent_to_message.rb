class AddUrgentToMessage < ActiveRecord::Migration
  def change
  	add_column :messages, :urgent, :boolean
  end
end
