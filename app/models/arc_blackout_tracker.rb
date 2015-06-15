class ArcBlackoutTracker < ActiveRecord::Base

	validates :arc_blackout_date_id, presence: true
	validates :arc_city_state_id, presence: true

	belongs_to :arc_blackout_date
	belongs_to :arc_city_state

end
