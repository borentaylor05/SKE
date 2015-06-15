class ArcBlackoutDate < ActiveRecord::Base

	validates :date, presence: true

	has_many :arc_blackout_trackers
	has_many :arc_city_states, through: :arc_blackout_trackers

end
