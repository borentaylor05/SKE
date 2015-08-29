class State < ActiveRecord::Base

	has_many :arc_city_states
	has_many :arc_city_state_groups

end
