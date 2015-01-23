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

