class ContentRequestController < ApplicationController
	before_action :access_check
	after_filter :cors_set_access_control_headers
	include ActionView::Helpers::DateHelper

	def all
		requests = []
		ContentRequest.where(client: Client.find_by(name: params[:client])).each do |c|
			r = {
				request_type: c.request_type,
				updated: "#{time_ago_in_words(c.updated_at)} ago",
				description: c.description
			}
			if c.request_type == "new"
				r[:docTitle] = c.title
				r[:docNum] = nil
			elsif c.request_type == "revision"
				r[:docNum] = c.content.doc_id
				r[:docTitle] = nil
			end	
			requests.push(r)
		end	
		respond(requests)
	end

	def new_content
		c = ContentRequest.new(
				title: params[:docTitle],
				description: params[:summary],
				request_type: params[:type],
				client: Client.find_by(name: params[:client])
			)
		if c.valid?
			c.save
			response = c
		else
			response = { status: 0, message: "#{c.errors.full_messages}" }
		end
		respond(response)
	end

	def revision
		c = ContentRequest.new(
			description: params[:summary],
			request_type: params[:type],
			content: Content.find_by(doc_id: params[:docNum]),
			client: Client.find_by(name: params[:client])
		)
		if c.valid?
			c.save
			response = c
		else
			response = { status: 0, message: "#{c.errors.full_messages}" }
		end
		respond(response)
	end

end