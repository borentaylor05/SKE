class MessageTracker < ActiveRecord::Base

	belongs_to :user
	belongs_to :message
	belongs_to :client

	default_scope { order('created_at DESC') }

end
