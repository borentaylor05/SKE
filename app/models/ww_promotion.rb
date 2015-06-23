class WwPromotion < ActiveRecord::Base

	validates :first_name, presence: true
	validates :last_name, presence: true
	validates :member_num, uniqueness: true, allow_nil: true
	validates :billing, presence: true
	validates :state, presence: true
	validates :zip, presence: true
	validates :meet_state, presence: true
	validates :meet_city, presence: true
	validates :member_phone, presence: true
	validates :description, presence: true
	validates :zip, presence: true
	validates :agent_name, presence: true

end
