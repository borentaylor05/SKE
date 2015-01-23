class CreateAToZEntries < ActiveRecord::Migration
  def change
    create_table :a_to_z_entries do |t|
      t.string :Topic
      t.string :AKA
      t.string :Owner
      t.string :Scope
      t.string :Notes
      t.string :ProgramFlow
      t.string :PRs
      t.string :CDC_link
      t.string :Spanish

      t.timestamps null: false
    end
  end
end
