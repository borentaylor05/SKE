class ArcBlackoutDate < ActiveRecord::Base

	############ NOTE
	# :notes is actually yellow date and corresponds with expires_yellow
	############

	has_many :arc_blackout_trackers
	has_many :arc_city_states, through: :arc_blackout_trackers
	
end