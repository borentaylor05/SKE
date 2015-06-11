class RcoOrder < ActiveRecord::Base

	validates :order_id, presence: true
	validates :agent_name, presence: true

	default_scope { order('updated_at DESC') }

end
