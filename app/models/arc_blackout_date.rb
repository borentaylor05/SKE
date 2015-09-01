class ArcBlackoutDate < ActiveRecord::Base

	validates :date, date_string: true # in lib/date_string_validator.rb
	validates :date_type, :inclusion=> { :in => ["black", "yellow"] }
	validate :date_or_notes?
	validate :if_date_then_expires?

	has_many :arc_blackout_trackers
	has_many :arc_city_states, through: :arc_blackout_trackers

	default_scope { order('expires ASC') }

	def date_or_notes?
		if !date and !notes
			errors.add(:arc_blackout_date, "date and notes cannot be nil")
		end
	end

	def if_date_then_expires?
		if date and !expires 
			errors.add(:arc_blackout_date, "valid date requires expires field")
		end
	end
	
end