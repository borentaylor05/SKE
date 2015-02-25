class ContentController < ApplicationController
	before_action :access_check
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers

	def generate_s3_json
		resp = {
			policy:    s3_upload_policy,
			signature: s3_upload_signature,
			key:       ENV['AWS_ACCESS_KEY_ID']
		}
		Rails.logger.info(resp)
		render json: resp
	end

	def all
		start = 0;
		count = 50;
		contents = []
		if params.has_key?("start")
			start = params[:start]
		end
		if params.has_key?("count")
			count = params[:count]
		end
		if !params.has_key?("client")
			Content.find_each(start: start, batch_size: count) do |c|
				content = {
					api_id: c.api_id,
					doc_id: c.doc_id,
					title: c.title
				}
				contents.push(content)
			end
		else
			Content.where(client: Client.find_by(name: params[:client])).limit(count).each do |c|
				content = {
					api_id: c.api_id,
					doc_id: c.doc_id,
					title: c.title
				}
				contents.push(content)
			end
		end
		respond(contents)
	end

	def create
		if(Content.find_by(api_id: params[:api_id]).blank?)
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
				featured: to_boolean(params[:featured])
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
		if Content.any?
			message = Content.find_by(api_id: params[:api_id]).message
			if !message.nil?
				respond({ message: message })
			else
				respond({message: ""})
			end
		else
			respond({ status: 0, error: "No Content" })
		end
	end
		
	def feature
		respond(set_feature)
	end

	def attach_message
		if Content.any?
			c = Content.find_by(api_id: params[:api_id])
			c.post.touch
			c.update_attributes(message: params[:message])
			respond({ status: 1 })	
		else
			respond({status: 0, error: "No Content"})
		end	
	end

	def update_client
		if Content.any?
			c = Content.find_by(api_id: params[:api_id])
			c.post.touch
			c.update_attributes(client_id: Client.find_by(name: params[:client]).id)
			respond({ status: 1 })
		else
			respond({status: 0, error: "No Content"})
		end
	end

	def webhooks_content
		wh_content_create(params)
	end

	def test
		u = get_user(2004, Client.first)
		respond({user: u})
	end

	private

		def s3_upload_policy
			@policy ||= create_s3_upload_policy
		end

		def create_s3_upload_policy
			Base64.encode64(
			{
				"expiration" => 1.hour.from_now.utc.xmlschema,
				"conditions" => [
					{ "bucket" =>  ENV['S3_BUCKET'] },
					[ "starts-with", "$key", "" ],
					{ "acl" => "public-read" },
					[ "starts-with", "$Content-Type", "" ],
					[ "content-length-range", 0, 10 * 1024 * 1024 ]
				]
			}.to_json).gsub(/\n/,'')
		end

		def s3_upload_signature
			Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), ENV['AWS_SECRET_ACCESS_KEY'], s3_upload_policy)).gsub("\n","")
		end

		def check_tags(content, tags)
			if !tags.blank?
				tags.split(",").each do |tag|
					s = Specialty.find_by(name: tag.downcase)
					# if tag has matching specialty
					if !s.blank?
						if !s.contents.include?(content)
							s.contents << content
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
			if Content.any?
				c = Content.find_by(api_id: params[:api_id])
				c.post.touch
				check_tags(c, params[:tags])
				c.update_attributes(featured: to_boolean(params[:featured]))
				return { status: 1 }
			else
				return { status: 0, error: "No content" }
			end
		end

		def wh_content_create(params)
			c = Content.find_by(api_id: params[:api_id])
			if c.nil?
				client = Client.find_by(kb_space_id: params[:client_kb_id].to_i)
				c = Content.new(
					api_id: params[:api_id],
					doc_id: params[:doc_id],
					title: params[:title],
					user: get_user(params[:jive_user_id], client), #creates the user if doesn't exist
					client: client,
					message: params[:message],
					cType: params[:type],
					featured: false
				)
				p = Post.new(user_id: c.user.id, client_id: c.client.id, action: c)
				if c.valid? && p.valid?
					c.save
					p.save
					check_tags(c, Jive.getTags("#{$current_url}/contents/#{c.api_id}", $current_auth))
					response = { status: 1, message: "Content created" }
				else
					response = { status: 0, error: "Content: #{c.errors.full_messages}, Post: #{p.errors.full_messages}" }
				end
			else
				c.post.touch
				c.update_attributes(message: params[:message])
				response = { status: 1, message: "Message updated" }
			end
			respond(response)
		end
end
