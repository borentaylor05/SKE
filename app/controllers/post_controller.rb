class PostController < ApplicationController
	include ActionView::Helpers::DateHelper
	def all
		if !params.has_key?("client") && Post.any?
			posts = []
			Post.all.each do |p|
				Rails.logger.info(p)
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
				end	
			end
		else
			posts = client_posts(params[:client])
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
				end	
			end
		end
		return posts
	end

end
