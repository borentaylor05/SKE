class OldCommentController < ApplicationController
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers

	def check
		if(request.method == "OPTIONS")
			respond({status: 1})
		elsif request.method == "POST"
			resp = []
			coms = JSON.parse(params[:data])
			coms.each do |com|
				Rails.logger.info(com)
				if OldComment.find_by(api_id: com["api"].to_i)
					c = OldComment.find_by(api_id: com["api"].to_i)
				else
					c = OldComment.new(
						api_id: com["api"],
						old_content: OldContent.find_by(api_id: com["content"].to_i),
						resolved: false
					)
					if c.valid?
						c.save
					else
						Rails.logger.info("Unable to save comment: #{c.errors.full_messages}")
					end
				end
				hash = c.attributes
				hash[:index] = com["index"]
				resp.push(hash)
			end
			respond(resp)
		else
			respond({})
		end
	end

end
