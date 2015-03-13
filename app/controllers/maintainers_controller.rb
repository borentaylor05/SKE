class MaintainersController < ApplicationController
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers


	def new_article_request
		if(request.method == "OPTIONS")
			respond({status: 1})
		elsif request.method == "POST"
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
					m = Maintainer.new(client: client, user: user, ticket: ar, resolved: false, lob: params[:lob])
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


end
