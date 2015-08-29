class ArcCityStateGroup < ActiveRecord::Base
	validates :name, presence: true
	validates :state_id, presence: true

	has_many :arc_group_trackers
	has_many :arc_city_states, through: :arc_group_trackers

	belongs_to :state

	def apify
		hash = self.attributes
		hash[:cities] = self.arc_city_states
		return hash	
	end

end
