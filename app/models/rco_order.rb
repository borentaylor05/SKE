class RcoOrder < ActiveRecord::Base

	validates :order_id, presence: true
	validates :lms_num, presence: true
	validates :coupon, presence: true
	validates :num_registrations, presence: true
	validates :agent_name, presence: true

	default_scope { order('updated_at DESC') }

end
