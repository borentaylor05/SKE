require 'Jive2'

class CDC

	def initialize(instance)
		@jive = Jive2.new(instance)
	end

	def import_address_book(file)
		CSV.foreach(file, headers: true) do |row|
			row[0] = row[0].strip # row[0] is Program Description
			entry = AddressBookEntry.find_by(ProgramDescription: row[0])
			if entry
				entry.update_attributes(row.to_hash)
			else
				ab = AddressBookEntry.create! row.to_hash
			end
		end
	end

	def import_a_to_z(file)
		CSV.foreach(file, headers: true) do |row|
			row[0] = row[0].strip # row[0] is Topic
			entry = AToZEntry.find_by(topic: row[0])
			if entry
				entry.update_attributes(row.to_hash)
			else
				AToZEntry.create! row.to_hash
			end
		end
	end

end