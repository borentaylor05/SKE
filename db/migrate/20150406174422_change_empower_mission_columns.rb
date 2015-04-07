class ChangeEmpowerMissionColumns < ActiveRecord::Migration
  def change
  	add_column :empower_missions, :units, :string
  end
end
