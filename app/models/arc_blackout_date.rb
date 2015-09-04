class ArcBlackoutDate < ActiveRecord::Base

	validates :date, date_string: true # in lib/date_string_validator.rb
	validates :date_type, :inclusion=> { :in => ["black", "yellow"] }
	validate :date_or_notes?
	validate :if_date_then_expires?

	has_many :arc_blackout_trackers
	has_many :arc_city_states, through: :arc_blackout_trackers

	default_scope { order('expires ASC') }

	def date_or_notes?
		if date.blank? and !notes
			errors.add(:arc_blackout_date, "date and notes cannot be nil or blank")
		end
	end

	def date_blank?
		if date == ""
			errors.add(:arc_blackout_date, "date cannot be blank")
		end
	end

	def if_date_then_expires?
		if date and !date.blank? and !expires 
			errors.add(:arc_blackout_date, "valid date requires expires field")
		end
	end

	def toggle_type(city)
		if self.date_type == "black"
			new_type = "yellow"
		elsif self.date_type == "yellow"
			new_type = "black"
		end
		switching_bo = ArcBlackoutDate.find_or_create_by(date: self.date, notes: self.notes, date_type: new_type)
		tracker = ArcBlackoutTracker.find_by(arc_blackout_date: self, arc_city_state: city)
		tracker.update_attributes(arc_blackout_date: switching_bo)
		return tracker
	end
	
end