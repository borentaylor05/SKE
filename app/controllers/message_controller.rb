class MessageController < ApplicationController
	include ActionView::Helpers::DateHelper
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers
	after_action :allow_iframe

	def get_unread_messages
		user = User.find_by(jive_id: params[:user])
		msgs = get_unread(user)
		respond({ status: 0, messages: msgs })
	end

	def acknowledge
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			user = User.find_by(jive_id: params[:user])
			m = MessageTracker.find_by(user: user, message_id: params[:message])
			m.update_attributes(acknowledged: true)
			respond({ status: 0, messages: get_unread(user) })
		end
	end

	def send_message
		if User.exists?(jive_id: params[:sender])
			u = User.find_by(jive_id: params[:sender])
			m = Message.new(
				user: u,
				text: params[:body],
				client: u.client
			)
			if m.valid?
				m.save
				m.send_message(params[:recipients])
				respond({ status: 0, message: "Message Sent to #{params[:recipients].count} people." })
			else
				respond({ status: 1, error: "#{m.errors.full_messages}" })
			end
		else
			respond({ status: 2, error: "Sender doesn't exist, creating now." })
		end
	end

	private

		def get_unread(user)
			msgs = []
			Rails.logger.debug(user.message_trackers.inspect)
			user.message_trackers.each do |t|
				if not t.acknowledged
					hash = t.message.attributes
					hash[:sender] = t.message.user
					msgs.push(hash)
				end
			end
			return msgs
		end

end

