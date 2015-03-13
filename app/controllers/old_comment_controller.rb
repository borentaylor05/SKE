class OldCommentController < ApplicationController
	include ActionView::Helpers::DateHelper
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers

	# checks each comment in array of document comments - creates if not exist 
	# Params: :data["api"(Jive API ID), "content"(api ID of parent content), "index"(array index of comment)]
	def check
		if(request.method == "OPTIONS")
			respond({status: 1})
		elsif request.method == "POST"
			if params.has_key?('data') and params[:data].class == Array
				resp = []
				error = {}
				coms = params[:data]
				coms.each do |com|
					if !com["api"]
						error = { error: "Error - Bad Request - API ID cannot be nil" }
						break
					elsif !com["content"]
						error = { error: "Error - Bad Request - Content API ID cannot be nil" }
						break	
					else
						c = OldComment.find_by(api_id: com["api"].to_i)
						if !c
							c = OldComment.new(
								api_id: com["api"],
								old_content: OldContent.find_by(api_id: com["content"].to_i),
								resolved: false
							)
							if c.valid?
								c.save
								u = User.find_by(jive_id: params[:user])
							else
								Rails.logger.info("Unable to save comment: #{c.errors.full_messages}")
							end
						end
						hash = c.attributes
						hash[:content] = c.old_content
						if c.comment_issue
							hash[:being_reviewed] = true
						else
							hash[:being_reviewed] = false
						end
						hash[:created_time_ago] = "#{time_ago_in_words(c.created_at)} ago"
						hash[:index] = com["index"]
						if hash[:resolved] == true
							hash[:resolved_time_ago] = "#{time_ago_in_words(hash[:resolved_at])} ago"
						end
						resp.push(hash)
					end
				end
				if error.blank?
					respond(resp)
				else
					respond(error)
				end
			else
				respond({ status: 1, error: "Request needs data property with content attributes. Data must be an array." })
			end
		end
	end

	def toggle
		if(request.method == "OPTIONS")
			respond({status: 1})
		elsif request.method == "POST"
			c = OldComment.find_by(api_id: params[:api])
			if params.has_key?("api") and c
				if c.resolved?
					c.old_content.update_attributes(comments: c.old_content.comments-1)
					c.update_attributes(resolved: false)
				else
					c.old_content.update_attributes(comments: c.old_content.comments+1)
					c.update_attributes(resolved: true, resolved_at: Time.now)
				end
				respond({status: 0, com: c})
			else
				Rails.logger.info("Comment #{params[:api]} does not exist");
				respond({ status: 1, error: "Comment #{params[:api]} does not exist" })
			end
		end
	end

end
