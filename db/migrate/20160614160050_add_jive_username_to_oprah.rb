class AddJiveUsernameToOprah < ActiveRecord::Migration
  def change
    add_column :ww_oprah_codes, :jive_username, :string
  end
end
