class OldContentController < ApplicationController
	require "Jive"
	require "Auth"
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

	# Params: :data["api"(Jive API ID), "commentCount", "doc"(Doc HTML URL), "title", "commentsUrl"]
	def check
		if(request.method == "OPTIONS")
			respond({status: 1})
		elsif request.method == "POST"
			if params.has_key?('data') and params[:data].class == Array
				docs = params[:data]
				resp = []
				created = []
				status = 0
				errors = ""
				docs.each do |d|
					c = OldContent.find_by(api_id: d["api"])
					test = c
					if c
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
							status = 1
							errors = "#{c.errors.full_messages}"
						end
					end
				end
				if status == 0
					respond({ status: 0, newComments: resp, created: created })
				else
					respond({ status: 1, error: errors })
				end
			else
				respond({ status: 1, error: "Request needs data property with content attributes. Data must be an array." })
			end
		end
	end

	private

		

end
