class EmpowerMission < ActiveRecord::Base

	validates :metric_name, presence: true
	validates :target, presence: true
	validates :target, numericality: true
	has_one :mission, as: :game

end
