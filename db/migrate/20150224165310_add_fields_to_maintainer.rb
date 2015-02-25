class AddFieldsToMaintainer < ActiveRecord::Migration
  def change
  	add_column :maintainers, :decision, :string
  	add_column :maintainers, :training_impact, :string
  end
end
