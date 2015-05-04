class AddLobToMission < ActiveRecord::Migration
  def change
  	add_column :missions, :lob, :string
  end
end
