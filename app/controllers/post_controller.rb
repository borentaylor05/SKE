class PostController < ApplicationController
	include ActionView::Helpers::DateHelper
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers
	
	def all
		if !params.has_key?("client") or params[:client] == "all" and Post.any?
			posts = []
			Post.all.each do |p|
				Rails.logger.info(p.action.inspect);
				resp = {
						title: p.action.title,
						updated: "#{time_ago_in_words(p.updated_at)} ago"
					}
				if p.action_type == "Update"
					resp[:body] = p.action.text
					resp[:type] = "update"
					resp[:id] = p.action.id
					posts.push(resp)
				elsif p.action_type == "Content"
					if p.action.featured
						resp[:body] = p.action.message
						resp[:type] = "content"
						resp[:id] = p.action.doc_id
						posts.push(resp)
					end
				elsif p.action_type == "Issue" and !p.action.resolved
					resp[:body] = p.action.summary
					resp[:type] = "issue"
					resp[:id] = p.action.content.doc_id
					resp[:resolved] = p.action.resolved
					resp[:post_id] = p.action.id
					posts.push(resp)
				end	
			end
		else
			if Post.any?
				posts = client_posts(params[:client])
			else
				posts = { status: 0, message: "No posts" }
			end
		end
		respond(posts)
	end

	private

	def client_posts(client)
		client_id = Client.find_by(name: client).id
		posts = []
		Post.all.each do |p|
			if p.action.client_id == client_id
				resp = {
						title: p.action.title,
						updated: "#{time_ago_in_words(p.updated_at)} ago"
					}
				if p.action_type == "Update"
					resp[:body] = p.action.text
					resp[:type] = "update"
					posts.push(resp)
				elsif p.action_type == "Content"
					if p.action.featured
						resp[:body] = p.action.message
						resp[:type] = "content"
						posts.push(resp)
					end
				elsif p.action_type == "Issue" and !p.action.resolved
					resp[:body] = p.action.summary
					resp[:type] = "issue"
					resp[:id] = p.action.content.doc_id
					resp[:resolved] = p.action.resolved
					resp[:post_id] = p.action.id
					posts.push(resp)
				end	
			end
		end
		return posts
	end

end
