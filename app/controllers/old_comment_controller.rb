class OldCommentController < ApplicationController
	include ActionView::Helpers::DateHelper
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers

	def check
		if(request.method == "OPTIONS")
			respond({status: 1})
		elsif request.method == "POST"
			resp = []
			coms = params[:data]
			coms.each do |com|
				Rails.logger.info("COOMENT----> #{com} ")
				if OldComment.exists?(api_id: com["api"].to_i)
					c = OldComment.find_by(api_id: com["api"].to_i)
				else
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
			respond(resp)
		else
			respond({})
		end
	end

	def toggle
		if(request.method == "OPTIONS")
			respond({status: 1})
		elsif request.method == "POST"
			if OldComment.exists?(api_id: params[:api])
				c = OldComment.find_by(api_id: params[:api])
				if c.resolved?
					c.old_content.update_attributes(comments: c.old_content.comments-1)
					c.update_attributes(resolved: false)
				else
					c.old_content.update_attributes(comments: c.old_content.comments+1)
					c.update_attributes(resolved: true, resolved_at: Time.now)
				end
				respond({status: 0})
			else
				Rails.logger.info("Comment #{params[:api]} does not exist");
				respond({ status: 1, error: "Comment #{params[:api]} does not exist" })
			end
		else
			respond({})
		end
	end

end
