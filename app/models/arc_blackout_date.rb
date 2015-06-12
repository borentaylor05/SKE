class ArcBlackoutDate < ActiveRecord::Base

	validates :date, presence: true

	belongs_to :arc_city_state

end
