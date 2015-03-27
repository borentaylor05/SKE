class MessageController < ApplicationController
	include ActionView::Helpers::DateHelper
	skip_before_action :verify_authenticity_token
	before_action :cors_set_access_control_headers
	after_action :allow_iframe

	def all
		user = User.find_by(jive_id: params[:user])
		if user.nil?
			respond({ status: 1, error: "User not found" })
		else
			msgs = get_all(user)
			respond({ status: 0, messages: msgs })
		end
	end

	# Params: { usser: :jive_id }
	def get_unread_messages
		user = User.find_by(jive_id: params[:user])
		if user 
			msgs = get_unread(user)
			respond({ status: 0, messages: msgs })
		else
			respond({ status: 1, error: "User #{params[:user]} not found." })
		end
	end

	def acknowledge
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			user = User.find_by(jive_id: params[:jive_id])
			if user 
				m = MessageTracker.find_by(user: user, message_id: params[:message])
				m.update_attributes(acknowledged: true)
				respond({ status: 0, messages: get_unread(user) })
			else
				respond({ status: 1, error: "User #{params[:jive_id]} not found" })
			end
		end
	end

	# needs Jive ID of sender and array of IDs for recipients
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

		def get_all(user)
			msgs = []
			user.message_trackers.limit(15).each do |t|
				hash = t.message.attributes
				hash["text"].gsub!(/\n/, '<br/>')
				hash[:sent_ago] = "#{time_ago_in_words(t.created_at)} ago"
				hash[:milli] = t.updated_at.to_f * 1000
				hash[:sender] = t.message.user
				hash[:acknowledged] = t.acknowledged
				msgs.push(hash)
			end
			return msgs
		end

		def get_unread(user)
			msgs = []
			Rails.logger.debug(user.message_trackers.inspect)
			user.message_trackers.each do |t|
				if not t.acknowledged
					hash = t.message.attributes
					hash["text"].gsub!(/\n/, '<br/>')
					hash[:sender] = t.message.user
					msgs.push(hash)
				end
			end
			return msgs
		end

end

