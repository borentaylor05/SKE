class MessageController < ApplicationController
	include ActionView::Helpers::DateHelper
	skip_before_action :verify_authenticity_token
	before_action :cors_set_access_control_headers
	after_action :allow_iframe

 	# for /messages/all -> { user: :jive_id }
	def all
		user = User.find_by(jive_id: params[:user])
		if user
			msgs = get_all(user)
			respond({ status: 0, messages: msgs })
		else
			respond({ status: 1, error: "User #{params[:user]} not found" })
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
			msg = Message.find_by(id: params[:message])
			if user and msg
				m = MessageTracker.find_by(user: user, message: msg)
				m.update_attributes(acknowledged: true)
				respond({ status: 0, messages: get_unread(user), acknowledged: m })
			else
				respond({ status: 1, error: "User #{params[:jive_id]} or message (#{params[:message]}) not found" })
			end
		end
	end

	# needs Jive ID of sender and array of Jive IDs for recipients
	# for /message -> { sender: :jive_id, body: text, recipients: [jive_ids] }
	def send_message
		u = User.find_by(jive_id: params[:sender])
		if u and params[:body].length > 0 and params[:recipients] and params[:recipients].count > 0
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
			if !u 
				respond({ status: 1, error: "Sender #{params[:sender]} doesn't exist, creating now." })
			elsif params[:body].length == 0
				respond({ status: 1, error: "Body cannot be empty." })
			elsif !params[:recipients] or params[:recipients].count == 0
				respond({ status: 1, error: "There must be at least one recipient." })
			end
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

