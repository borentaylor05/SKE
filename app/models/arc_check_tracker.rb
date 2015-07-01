class ArcCheckTracker < ActiveRecord::Base

	validates :check_num, presence: true
	validates :agent_name, presence: true
	validates :check_date, presence: true
	validates :org, presence: true
	validates :check_amount, presence: true
	validates :case_id, presence: true
	validates :check_name, presence: true
	validates :state, presence: true
	validates :tsc_received, presence: true

end
