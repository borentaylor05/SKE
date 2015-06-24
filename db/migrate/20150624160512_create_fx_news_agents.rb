class CreateFxNewsAgents < ActiveRecord::Migration
  def change
    create_table :fx_news_agents do |t|
      t.string :code
      t.string :agent
      t.string :fax_email

      t.timestamps null: false
    end
  end
end
