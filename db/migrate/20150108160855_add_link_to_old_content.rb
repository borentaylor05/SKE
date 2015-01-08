class AddLinkToOldContent < ActiveRecord::Migration
  def change
  	add_column :old_contents, :link, :string
  end
end
