class AddLobToMaintainers < ActiveRecord::Migration
  def change
  	add_column :maintainers, :lob, :string
  end
end
