require 'Jive2'
require 'Util'

class RedCross 

	def initialize(instance)
		@jive = Jive2.new(instance)
	end

	def bo_dates
		current_state = ""
		current_city = ""
		current_date = ""
		current_notes = ""
		CSV.foreach('bo_61115.csv', headers: true) do |row|
			if row[0] and row[0] != current_state
				current_state = row[0].strip
			end
			if row[1] and row[1] != current_city
				current_city = row[1].strip
			end
			if row[2] and row[2] != current_date
				current_date = row[2].strip
			end
			if row[3] and row[3] != current_notes
				current_notes = row[3].strip
			end
			puts "#{current_city}, #{current_state} -- #{current_date} ----> #{current_notes}"
		end
	end

end