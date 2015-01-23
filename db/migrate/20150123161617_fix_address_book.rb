class FixAddressBook < ActiveRecord::Migration
  def change
  	rename_column :address_book_entries, :Program, :ProgramDescription
  	rename_column :address_book_entries, :AKA, :AlternateTopicName
  	rename_column :address_book_entries, :CIO, :Owner
  	rename_column :address_book_entries, :Comments, :CommentText
  end
end
