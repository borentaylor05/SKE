class Message < ActiveRecord::Base

	belongs_to :client
	belongs_to :group #sending to group
	belongs_to :user # user is sender
	# many to many b/t user and msg to track read messages
	has_many :message_trackers
	has_many :users, through: :message_trackers	
	has_many :clients, through: :message_trackers	

	def send_message(recipients)
		recipients.each do |r|
			t = MessageTracker.new(
				message: self,
				user: User.find_by(jive_id: r)
			)
			t.save
		end
	end

end
