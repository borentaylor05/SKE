class ArcCityState < ActiveRecord::Base

	validates :city, presence: true
	validates :state, presence: true

	has_many :arc_blackout_dates

end
