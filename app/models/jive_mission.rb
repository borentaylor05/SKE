class JiveMission < ActiveRecord::Base

	has_one :mission, as: :game

end
