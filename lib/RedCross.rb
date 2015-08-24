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
		current_date = ""
		current_notes = ""
		CSV.foreach('arc_blackout_72415.csv', headers: true) do |row|
			if row[1] and row[1] != current_city
				current_city = row[1].strip
				current_notes = nil
				current_date = nil
				current_state = nil
			end
			if row[0] and row[0] != current_state
				current_state = State.find_or_create_by(abbreviation: row[0].strip.upcase)
			end			
			if row[2] and row[2] != current_date
				current_date = row[2].strip
			end
			if row[3] and row[3] != current_notes
				current_notes = row[3].strip
			end
			if current_city and current_state and (current_date or current_notes)
				city = ArcCityState.find_by(city: current_city.downcase, state: current_state)
				if !city 
					city = ArcCityState.create!(city: current_city.downcase, state: current_state)
				end
				bo = ArcBlackoutDate.find_by(date: current_date, notes: current_notes)
				if !bo 
					bo = ArcBlackoutDate.create!(date: current_date, notes: current_notes)
				end
				if !ArcBlackoutTracker.exists?(arc_city_state: city, arc_blackout_date: bo)
					ArcBlackoutTracker.create(arc_city_state: city, arc_blackout_date: bo)
				end
			else
				puts "ERROR------> #{current_city}, #{current_state} -- #{current_date} ----> #{current_notes} <----ERROR"
			end
		end
		State.all.each do |s|
			s.update_attributes(name: "UNKNOWN") if s.name.nil?
		end
	end

end