module ArcHelper
	def is_valid_date_string?(string)
		if string
			if string.include?("-")
				parts = string.split("-").map { |d| d.strip }
				string = parts[parts.length - 1]
			end
			parts = string.split("/")
			if parts.count == 3
				return true if valid_month?(parts[0]) and valid_day?(parts[1]) and valid_year?(parts[2])
			end
			return false
		else
			return true
		end
	end

	def valid_month?(month)
		if month.numeric? and month.to_i < 13
			return true 
		end
		return false
	end

	def valid_day?(day)
		if day.numeric? and day.to_i < 32
			return true 
		end
		return false
	end

	def valid_year?(year)
		if year.numeric? and year.to_i < 2020 and year.to_i >= 2015
			return true 
		end
		return false
	end

	def parse_arc_bo_date(date_string)
		begin
			if date_string.include?("-")
				start, date_string = date_string.split("-")  
			end
			if is_valid_date_string?(date_string)
				return date_string ? Date.strptime(date_string, '%m/%d/%Y') : nil
			else
				return nil 
			end
		rescue ArgumentError, TypeError
			puts "ERROR: Invalid Date #{date_string}"
			return nil
		end
	end

end

class String
	def numeric?
		true if Float(self) rescue false
	end
end
