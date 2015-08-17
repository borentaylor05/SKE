class ArcCheckTracker < ActiveRecord::Base

	validates :check_num, presence: true
	validates :agent_name, presence: true
	validates :check_date, presence: true
	validates :check_amount, presence: true
	validates :case_id, presence: true
	validates :check_name, presence: true
	validates :state, presence: true
	validates :tsc_received, presence: true

	default_scope { order('updated_at DESC') }
	scope :search_string, -> (search) { where("lower(agent_name) like ? or lower(org) like ? or lower(check_name) like ? or lower(order_num) like ? or lower(crs) like ?", "%#{search.downcase}%", "%#{search.downcase}%", "%#{search.downcase}%", "%#{search.downcase}%", "%#{search.downcase}%")}
	scope :search_numeric, -> (search) { where("cast(check_num as varchar) like ? or cast(check_amount as varchar) like ? or cast(case_id as varchar) like ? or order_num like ? or crs like ?", "%#{search.to_s}%", "%#{search.to_s}%", "%#{search.to_s}%", "%#{search.to_s}%", "%#{search.to_s}%" )}

end
