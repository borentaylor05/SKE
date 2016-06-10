class CreateWwOprahTrackers < ActiveRecord::Migration
  def change
    create_table :ww_oprah_trackers do |t|
      t.string :caller_issue
      t.string :referral_type
      t.string :member_sub
      t.string :non_working_code
      t.datetime :signup_date
      t.string :referral_location

      t.timestamps null: false
    end
  end
end
