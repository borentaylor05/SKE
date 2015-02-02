class AddIndexToPubNameInDeadlines < ActiveRecord::Migration
  def change
  	add_index :deadlines, :publication
  end
end
