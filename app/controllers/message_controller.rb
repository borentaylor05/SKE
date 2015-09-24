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
			if user.pending_urgent
				user.update_attributes(pending_urgent: false)
			end
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
	# for /message -> { sender: :jive_id, body: text, groups: [lobs or title for a client] }
	def send_message
		puts "MESSAGE PARAMS - #{params}"
		u = User.find_by(jive_id: params[:sender])
		if u and !params[:body].blank? and params[:groups] and params[:groups].count > 0
			m = Message.new(
				user: u,
				text: params[:body],
				client: u.client,
				urgent: params[:urgent]
			)
			if m.valid?
				m.save
				recipients = get_people_from_groups(params[:groups])
				m.send_message(recipients)
				respond({ status: 0, message: "Message Sent to #{recipients.count} people.", users: recipients })
			else
				respond({ status: 1, error: "#{m.errors.full_messages}" })
			end
		else
			if !u 
				respond({ status: 1, error: "Sender #{params[:sender]} doesn't exist, creating now." })
			elsif params[:body].length == 0
				respond({ status: 1, error: "Body cannot be empty." })
			elsif !params[:groups] or params[:groups].count == 0
				respond({ status: 1, error: "There must be at least one recipient." })
			end
		end
	end

	# /api/clients/:client/lobs-titles
	def get_lobs_titles_for_client
		if numeric?(params[:client])
			client = Client.find_by(id: params[:client])
		else
			client = Client.find_by(name: params[:client].downcase)
		end
		if client
			lobs = get_client_lobs(client.id)
			if lobs.count > 0
				respond({ status: 0, lobs: lobs })
			else
				respond({ status: 1, error: "No LOBS found.  Need to upload users." })
			end
		else
			respond({ status: 1, error: "Client not found." })
		end
	end

	private

		# groups = titles and lobs
		def get_people_from_groups(groups)
			users = []
			groups.each do |g|
				if g[:name] == 'Admins'
					matches = User.where(client: Client.find_by(name: 'all')).select(:jive_id)
				elsif g[:type] == 'lob'
					matches = User.where(lob: g[:name]).select(:jive_id)
				elsif g[:type] == 'title'
					matches = User.where(title: g[:name]).select(:jive_id)
				end	
				users.push(*matches)				
			end
			return users;
		end

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

		def get_client_lobs(client_id)
			return User.where(client_id: client_id).uniq.pluck(:lob).sort_by(&:to_s)
		end

		def get_client_titles(client_id)
			return User.where(client_id: client_id).uniq.pluck(:title).sort_by(&:to_s)
		end

end

