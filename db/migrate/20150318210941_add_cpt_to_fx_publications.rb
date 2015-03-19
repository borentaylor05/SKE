class AddCptToFxPublications < ActiveRecord::Migration
  def change
  	add_column :fx_publications, :cost_per_thousand, :integer
  end
end
