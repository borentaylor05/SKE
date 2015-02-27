class OldContentController < ApplicationController
	require "Jive"
	require "Auth"
	before_action :access_check
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers

	def new_doc
	
	end

	def subtract_replies
		if(request.method == "OPTIONS")
			respond({status: 1})
		elsif request.method == "POST"
			oc = OldContent.find_by(api_id: params[:doc])
			cur = oc.comments
			oc.update_attributes(comments: cur - params[:subtract].to_i)
			respond({ status: 0, count: oc.comments })
		end
	end

	def check
		if(request.method == "OPTIONS")
			respond({status: 1})
		elsif request.method == "POST"
			docs = params[:data]
			resp = []
			created = []
			docs.each do |d|
				if OldContent.exists?(api_id: d["api"])
					c = OldContent.find_by(api_id: d["api"])
					if d["commentCount"].to_i > c.comments
						hash = c.attributes
						hash[:dif] = d["commentCount"].to_i - c.comments
						resp.push(hash)
					elsif d["commentCount"].to_i < c.comments
						# means someone deleted something
						c.update_attributes(comments: d["commentCount"].to_i)
					end
				else
					c = OldContent.new(
						api_id: d["api"], 
						comments: d["commentCount"].to_i, 
						link: d["doc"],
						commentsUrl: d["commentsUrl"],
						title: d["title"]
					)
					if c.valid?
						c.save
						created.push(c)
					else
						Rails.logger.info(c.errors.full_messages)
					end
				end
			end
			respond({ newComments: resp, created: created })
		end
	end

	private

		

end
