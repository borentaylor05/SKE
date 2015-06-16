class RcoOrder < ActiveRecord::Base

	validates :agent_name, presence: true
	validates :order_id, uniqueness: false

	default_scope { order('updated_at DESC') }

end
