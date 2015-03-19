class CreateCostPerThousandsFxPublicationsJoinTable < ActiveRecord::Migration
  def change
  	create_table :cost_per_thousands_fx_publications do |t|
      t.integer :cost_per_thousand_id
      t.integer :fx_publication_id

      t.timestamps null: false
    end
  end
end
