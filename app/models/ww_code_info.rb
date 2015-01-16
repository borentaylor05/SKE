class WwCodeInfo < ActiveRecord::Base

	validates :sub_num, presence: true
	validates :member_last_name, presence: true
	validates :member_first_name, presence: true
	validates :agent_id, presence: true
	validates :token, presence: true
	validates_uniqueness_of :token
	belongs_to :ww_code

end
