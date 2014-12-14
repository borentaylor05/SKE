class ContentController < ApplicationController
	include ActionView::Helpers::SanitizeHelper
	skip_before_action :verify_authenticity_token

	def create
		if(Content.find_by(api_id: params[:api_id]).blank?)
			message = strip_tags(params[:message])[58...300]
			message = "#{message}..."
			if params[:client] == "undefined"
				client_id = 0
			else
				client_id = Client.find_by(name: params[:client]).id
			end
			uid = User.find_by(jive_id: params[:jive_id]).id
			c = Content.new(api_id: params[:api_id], 
				doc_id: params[:doc_id], 
				title: params[:title],
				user_id: uid,
				client_id: client_id,
				featured: to_boolean(params[:featured]),
				message: message
			)
			p = Post.new(user_id: uid, client_id: client_id, action: c)
			c.post = p
			if c.valid? && p.valid?
				c.save
				p.save
				check_tags(c, params[:tags])
				response = { status: 1 }
			else
				response = { status: 0, error: "Content: #{c.errors.full_messages}, Post: #{p.errors.full_messages}" }
			end
		else
			response = set_feature
		end
		respond(response)
	end

	def get_message
		message = Content.find_by(api_id: params[:api_id]).message
		if !message.nil?
			respond({ message: message })
		else
			respond({message: ""})
		end
	end
		
	def feature
		respond(set_feature)
	end

	def attach_message
		c = Content.find_by(api_id: params[:api_id])
		c.post.touch
		c.update_attributes(message: params[:message])
		respond({ status: 1 })		
	end

	def update_client
		c = Content.find_by(api_id: params[:api_id])
		c.post.touch
		c.update_attributes(client_id: Client.find_by(name: params[:client]).id)
		respond({ status: 1 })
	end

	def webhooks
		Rails.logger.info("PARAMS: #{params.to_json}")
		Rails.logger.debug(request.body)
		respond({})
	end

	private

		def check_tags(content, tags)
			if !params[:tags].blank?
				tags.split(",").each do |tag|
					s = Specialty.find_by(name: tag.downcase)
					# if tag has matching specialty
					if !s.blank?
						if !s.contents.include?(content)
							s.contents << content
						#	content.specialties << s
							if s.valid? && content.valid?
								s.save
								content.save
							else
								respond({error: "Spec: #{s.errors.full_messages}, Content: #{content.errors.full_messages}"})
							end
						end
					end
				end
			end
		end

		def set_feature
			c = Content.find_by(api_id: params[:api_id])
			c.post.touch
			check_tags(c, params[:tags])
			c.update_attributes(featured: to_boolean(params[:featured]))
			return { status: 1 }
		end

end
