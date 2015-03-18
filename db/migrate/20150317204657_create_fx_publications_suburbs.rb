class CreateFxPublicationsSuburbs < ActiveRecord::Migration
  def change
    create_table :fx_publications_suburbs do |t|
      t.integer :fx_publication_id
      t.integer :suburb_id

      t.timestamps null: false
    end
  end
end
