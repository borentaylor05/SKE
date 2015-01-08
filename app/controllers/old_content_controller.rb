class OldContentController < ApplicationController
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers

	def new_doc
		

	end

	def test
		if(request.method == "OPTIONS")
			respond({status: 1})
		elsif request.method == "POST"
			docs = JSON.parse(params[:data])
			resp = []
			docs.each do |d|
				if OldContent.exists?(api_id: d["api"])
					c = OldContent.find_by(api_id: d["api"])
					if d["commentCount"].to_i > c.comments
						hash = c.attributes
						hash[:dif] = d["commentCount"].to_i - c.comments
						resp.push(hash)
					end
				else
					c = OldContent.new(
						api_id: d["api"], 
						comments: d["commentCount"].to_i, 
						link: d["doc"],
						commentsUrl: d["commentsUrl"]
					)
					if c.valid?
						c.save
					else
						Rails.logger.info(c.errors.full_messages)
					end
				end
			end
			respond(resp)
		end
	end

end
