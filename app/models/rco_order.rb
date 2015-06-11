class RcoOrder < ActiveRecord::Base

	validates :agent_name, presence: true

	default_scope { order('updated_at DESC') }

end
