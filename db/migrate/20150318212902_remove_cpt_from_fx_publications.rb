class RemoveCptFromFxPublications < ActiveRecord::Migration
  def change
	remove_column :fx_publications, :cost_per_thousand		  	
  end
end
