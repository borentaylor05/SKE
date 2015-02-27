class MaintainersController < ApplicationController
	require 'Jive'
	skip_before_action :verify_authenticity_token
	before_action :access_check
	after_filter :cors_set_access_control_headers
#	before_action :authenticate_admin!, except: [:new_article_request]

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
				my_admin_user = User.find_by(jive_id: 99999999)
				logger.info("ADMIN ------------> #{my_admin_user}")
				msg = Message.new(
					user: my_admin_user, # sender is system admin user (jive_id = 99999999)
					text: message,
					client: my_admin_user.client
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
			if m.do_delete == true
				m.destroy
				m.ticket.destroy
			else
				ms.push(m.makeRelevant)
			end
		end
		respond({ m: ms })
	end

	def new_article_request
		if(request.method == "OPTIONS")
			respond({status: 1})
		elsif request.method == "POST"
			Rails.logger.info("PARAMS ----> #{params}")
			if params[:admin]
				user = current_admin
			else
				user = User.find_by(jive_id: params[:user])
			end
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
					if params[:admin] and admin_signed_in?
						logger.info("ADMIN ------------------------> ")
						m = Maintainer.new(client: current_admin.client, admin: current_admin, ticket: ar, resolved: false)
					else
						logger.info("USER ------------------------> ")
						m = Maintainer.new(client: client, user: user, ticket: ar, resolved: false)
					end
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

	def new_comment_maintainer
		if(request.method == "OPTIONS")
			respond({status: 1})
		elsif request.method == "POST"
			user = User.find_by(jive_id: params[:user][:jive_id])
			if user
				oc = OldComment.find_by(id: params[:com])
				if oc and !oc.comment_issue
					ci = CommentIssue.new(old_comment: oc)
					ci.save
					m = Maintainer.new(ticket: ci, user: user)
					if m.valid? 
						m.save
						respond({ status: 0 })
					else
						respond({ status: 1, error: "#{m.errors.full_messages}" })
					end
				elsif oc.comment_issue
					oc.comment_issue.destroy
					oc.comment_issue.maintainer.destroy
					respond({ status: 0, message: "Issue removed." })
				else
					respond({ status: 1, error: "Comment not found" })
				end 
			else
				user_quick_create(params[:user])
			end
		end
	end

	private

	def maintainer_update_params
		params.require(:maintainer).permit(:pcf, :resolved, :training_impact, :response, :decision)
	end

	def determine_type(maintainer, message)
		case maintainer.ticket_type
		when "CommentIssue"
			message = "In response to comment #{maintainer.ticket.old_content.link}#comment-#{maintainer.ticket.api_id} \n\n #{message}"
		when "ArticleRequest"
			message = "In response to your article request titled: '#{maintainer.ticket.title}' \n\n #{message}"
		end
		return message
	end

end
