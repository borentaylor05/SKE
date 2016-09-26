class CreateLighthouseHtmls < ActiveRecord::Migration
  def change
    create_table :lighthouse_htmls do |t|
      t.string :client
      t.text :html

      t.timestamps null: false
    end
  end
end
