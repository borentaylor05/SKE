require 'Jive2'
require 'Util'

class RedCross 

	def initialize(instance)
		@jive = Jive2.new(instance)
	end

	def upload_check_tracker(file)
		good = 0
		errors = []
		ArcCheckTracker.destroy_all
		CSV.foreach(file.path, headers: true) do |row|
			if row[0]
				order = row[8] || row[9]
				check = ArcCheckTracker.new(
					check_num: row[0].strip,
					check_amount: row[1].to_s.gsub(/[$,]/,'').to_f,
					check_date: row[2],
					org: row[3],
					case_id: row[4],
					check_name: row[5],
					state: row[6],
					tsc_received: row[7],
					order_num: row[8],
					crs: row[9],
					notes: row[10],
					sent_back_by: row[11],
					agent_name: "OLD DATA"
				)
				check.save(validate: false)
			end
		end
		return { good: good, errors: errors }
	end
	
	def bo_dates
		current_state = ""
		current_city = ""
		current_bo = ""
		current_yellow = ""
		CSV.foreach('arc_blackout_72415.csv', headers: true) do |row|
			if row[1] and row[1] != current_city
				current_city = row[1].strip
				current_yellow = nil
				current_bo = nil
				current_state = nil
			end
			if row[0] and row[0] != current_state
				current_state = State.find_or_create_by(abbreviation: row[0].strip.upcase)
			end			
			if row[2] and row[2] != current_bo
				current_bo = row[2].strip
			else
				current_bo = nil if row[2] != current_bo
			end
			if row[3] and row[3] != current_yellow
				current_yellow = row[3].strip
			else
				current_yellow = nil if row[3] != current_yellow
			end
			if current_city and current_state and (current_bo or current_yellow)
				city = ArcCityState.find_by(city: current_city.downcase, state: current_state)
				if !city 
					city = ArcCityState.create!(city: current_city.downcase, state: current_state)
				end
				bo = ArcBlackoutDate.find_by(date: current_bo, date_type: "black")
				yellow = ArcBlackoutDate.find_by(date: current_yellow, date_type: "yellow")
				if !bo 
					bo = new_date(current_bo, "black")
				end
				if !yellow 
					yellow = new_date(current_yellow, "yellow")					
				end
				ArcBlackoutTracker.find_or_create_by(arc_city_state: city, arc_blackout_date: yellow)
				ArcBlackoutTracker.find_or_create_by(arc_city_state: city, arc_blackout_date: bo)
			end
		end
		State.all.each do |s|
			s.update_attributes(name: "UNKNOWN") if s.name.nil?
		end
	end

	private

		def parse_arc_bo_date(date_string)
			begin
				if date_string.include?("-")
					start, date_string = date_string.split("-")  
				end
				return date_string ? Date.strptime(date_string, '%m/%d/%Y') : nil
			rescue ArgumentError, TypeError
				puts "ERROR: Invalid Date #{date_string}"
				return nil
			end
		end

		def new_date(date, type)
			if date 
				expires = parse_arc_bo_date(date)
				if expires
					bo = ArcBlackoutDate.new(date: date, notes: nil, expires: expires, date_type: type)
				else
					bo = ArcBlackoutDate.new(date: date, notes: nil, expires: nil, date_type: type)
				end
				bo.save(validate: false)
				return bo
			end
		end

end