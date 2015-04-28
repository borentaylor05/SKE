class AddressBookEntry < ActiveRecord::Base
require 'CDC'

	scope :contains, -> (name) { where("lower('ProgramDescription') like ?", "%#{name.downcase}%") }

	def self.import(file)
		cdc = CDC.new('social')
		cdc.import_address_book(file.path)
	end

end
