class AddIndexToNewsagentCode < ActiveRecord::Migration
  def change
  	add_index :fx_news_agents, :code
  end
end
