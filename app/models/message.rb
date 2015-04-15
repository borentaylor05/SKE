class Message < ActiveRecord::Base

	belongs_to :client
	belongs_to :group #sending to group
	belongs_to :user # user is sender
	# many to many b/t user and msg to track read messages
	has_many :message_trackers
	has_many :users, through: :message_trackers	
	has_many :clients, through: :message_trackers	

	default_scope { order('created_at DESC') }

	def send_message(recipients)
		recipients.each do |r|
			u = User.find_by(jive_id: r.jive_id)
			if self.urgent
				u.update_attributes(pending_urgent: true) # helps avoid continuous scanning of messages
			end
			t = MessageTracker.new(
				message: self,
				user: u
			)
			t.save
		end
	end

end
