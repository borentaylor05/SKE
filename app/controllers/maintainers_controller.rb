class MaintainersController < ApplicationController
	require 'Jive'
	skip_before_action :verify_authenticity_token
	before_action :access_check
	after_filter :cors_set_access_control_headers
	before_action :authenticate_admin!, except: [:new_article_request]

	def index
		@user = current_admin
	end

	def update_maintainer
		m = Maintainer.find_by(id: params[:maintainer][:id])
		prevDecision = m.decision
		prevResponse = m.response
		if m.update_attributes(maintainer_update_params)
			respond({ status: 0, message: "Maintainer Updated" })
			# send message to requester containing new decision and response
			message = ""
			if m.response != prevResponse
				message = "Response: #{m.response} \n\n"
			end	
			if m.decision != prevDecision
				message =  "#{message}Decision: #{m.decision}</br>"
			end
			if message.length > 0
				message = determine_type(m, message)
				msg = Message.new(
					user: $admin_user, # sender is system admin user (jive_id = 99999999)
					text: message,
					client: $admin_user.client
				)
				if msg.valid?
					Rails.logger.info("MESSAGE -----> #{msg.user.jive_id}")
					msg.save
					msg.send_message([m.user.jive_id])
				else
					Rails.logger.info("ERROR -----> #{m.errors.full_messages}")
				end
			end
		else
			respond({ status: 1, error: "Unable to save" })
		end
	end

	def toggle_resolved
		m = Maintainer.find_by(id: params[:id])
		if m
			if m.resolved
				m.update_attributes(resolved: false)
			else
				m.update_attributes(resolved: true)
			end
			respond({ status: 0, message: "Toggled" })
		else
			respond({ status: 1, error: "Maintainer not found" })
		end
	end

	def get_maintainers
		ms = []
		Maintainer.limit(50).each do |m|
			ms.push(m.makeRelevant)
		end
		respond({ m: ms })
	end

	def new_article_request
		if(request.method == "OPTIONS")
			respond({status: 1})
		elsif request.method == "POST"
			Rails.logger.info("PARAMS ----> #{params}")
			user = User.find_by(jive_id: params[:user])
			if user.nil?
				respond({ status: 1, error: "User not found", type: "NoUser" })
			elsif user.client.nil? && params[:client].blank?
				respond({ status: 1, error: "No client for user", type: "NoClient" })			
			else
				if params[:client].blank?
					client = user.client
				else
					client = Client.find_by(name: params[:client])
				end
				ar = ArticleRequest.new(
					title: params[:title],
					summary: params[:summary]
				)
				if params.has_key?("file_label")
					ar.file_label = params[:file_label]
				end
				if params.has_key?("file_url")
					ar.file_url = params[:file_url]
				end
				if ar.valid?
					ar.save
					m = Maintainer.new(client: client, user: user, ticket: ar, resolved: false)
					if m.valid?
						m.save
						respond({ status: 0, message: "Article Request Saved!" })
					else
						respond({ status: 1, error: "#{m.errors.full_messages}" })
					end
				else
					respond({ status: 1, error: "#{ar.errors.full_messages}" })
				end
			end
		end
	end

	private

	def maintainer_update_params
		params.require(:maintainer).permit(:pcf, :resolved, :training_impact, :response, :decision)
	end

	def determine_type(maintainer, message)
		case maintainer.ticket_type
		when "OldComment"
			message = "In response to comment #{maintainer.ticket.old_content.link}#comment-#{maintainer.ticket.api_id} \n\n #{message}"
		when "ArticleRequest"
			message = "In response to your article request titled: '#{maintainer.ticket.title}' \n\n #{message}"
		end
		return message
	end

end
