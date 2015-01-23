class CreateAddressBookEntries < ActiveRecord::Migration
  def change
    create_table :address_book_entries do |t|
      t.string :Program
      t.string :AKA
      t.string :CIO
      t.string :LastName
      t.string :FirstName
      t.string :EmailAddress
      t.string :WorkPhone
      t.string :Comments

      t.timestamps null: false
    end
  end
end
