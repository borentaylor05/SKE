class WwPromotion < ActiveRecord::Base

	validates :first_name, presence: true
	validates :last_name, presence: true
	validates :member_num, presence: true
	validates :member_num, uniqueness: true
	validates :gender, presence: true, length: { maximum: 1 }
	validates :billing, presence: true
	validates :state, presence: true
	validates :zip, presence: true
	validates :agent_name, presence: true

end
