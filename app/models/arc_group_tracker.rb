class ArcGroupTracker < ActiveRecord::Base
	validates :arc_city_state_group_id, presence: true 
	validates :arc_city_state_id, presence: true

	belongs_to :arc_city_state
	belongs_to :arc_city_state_group

end
