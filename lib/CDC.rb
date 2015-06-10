require 'Jive2'

class CDC

	def initialize(instance)
		@jive = Jive2.new(instance)
	end

	def import_address_book(file)
		CSV.foreach(file, headers: true) do |row|
			row[0] = row[0].strip if row[0] # row[0] is Program Description
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
			row[0] = row[0].strip if row[0] # row[0] is Topic
			entry = AToZEntry.find_by(topic: row[0])
			if entry
				entry.update_attributes(
					aka: row[1],
					owner: row[2],
					scope: row[3],
					notes: row[4],
					program_flow: row[5],
					pr: row[6],
					cdc_link: row[7],
					spanish: row[8]
				)
			else
				AToZEntry.create!(
					topic: row[0],
					aka: row[1],
					owner: row[2],
					scope: row[3],
					notes: row[4],
					program_flow: row[5],
					pr: row[6],
					cdc_link: row[7],
					spanish: row[8]
				)
			end
		end
	end

	def import_gamification(file)
		errors = []
		CSV.foreach(file.path, headers: true) do |row|
			row.each do |r|
				if r == "---"
					r = nil
				end
			end
			if row.count == 5
				user = User.find_by(employee_id: row[0])
				Rails.logger.info(row[0])
				if user 
					if !user.update_attributes(comp_score: row[2], rank: row[3], tier: row[4])
						Rails.logger.info("Error updating.")
						errors.push row[0]
					end
				else
					Rails.logger.info "User #{row[0]} not found."
					errors.push row[0]
				end
			else
				Rails.logger.info("CSV wrong format")
				errors.push "Wrong format at #{row[0]}!"
				return errors
			end
		end
		return errors
	end

end