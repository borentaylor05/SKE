class AddTitleToOldContent < ActiveRecord::Migration
  def change
  	add_column :old_contents, :title, :string
  end
end
