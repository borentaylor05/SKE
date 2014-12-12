class CreateJoinTableContentSpecialty < ActiveRecord::Migration
  def change
    create_join_table :contents, :specialties do |t|
       t.index [:content_id, :specialty_id]
       t.index [:specialty_id, :content_id]
    end
  end
end
