class ArcCityState < ActiveRecord::Base

	validates :city, presence: true
	validates :state, presence: true

	has_many :arc_blackout_trackers
	has_many :arc_blackout_dates, through: :arc_blackout_trackers

	belongs_to :state

end
