class AddKbUrlToClients < ActiveRecord::Migration
  def change
  	add_column :clients, :kb_url, :string
  end
end
