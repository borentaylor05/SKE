class CreateRedeliveries < ActiveRecord::Migration
  def change
    create_table :redeliveries do |t|
      t.integer :fx_publication_id
      t.string :town
      t.string :round_id
      t.boolean :redelivery
      t.string :cutoff_mf
      t.string :cutoff_sat
      t.string :cutoff_sun

      t.timestamps null: false
    end
  end
end
