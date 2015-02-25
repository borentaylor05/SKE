class UserController < ApplicationController
	include ActionView::Helpers::DateHelper
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers
	after_action :allow_iframe # part of IE fix

	# see if user is in db
	def check_init
		if User.exists?(jive_id: params[:user])
			u = User.find_by(jive_id: params[:user])
			respond({ status: 0, message: "User exists", user: u, client: u.client })
		else
			respond({ status: 1, error: "User is not in DB." })
		end
	end

	def search
		users = []
		User.contains(params[:term]).each do |u|
			hash = u.attributes 
			hash[:client] = u.client ? u.client.name : nil
			users.push(hash)
		end
		respond({ status: 0, users: users })
	end

	def create
		if(request.method == "OPTIONS")
			respond({status: 1})
		elsif request.method == "POST"
			user = parse_user(params)
			if !User.exists?(jive_id: user[:jive_id])
				u = User.new(jive_id: user[:jive_id], 
							 employee_id: user[:employee_id], 
							 client_id: user[:client_id],
							 name: user[:name]	
							 )
				if u.valid?
					u.save
					response = { status: 0, message: "User Created" }
				else
					response = { status: 1, error: "Error: #{u.errors.full_messages}" }
				end
			else
				if !params[:client].blank?
					update_user_client(params)
				end
				response = { status: "User Exists" }
			end
			respond(response)
		end
	end

	def update_client
		respond(update_user_client(params))
	end

	def get
		user = User.find_by(jive_id: params[:jive])
		if user
			hash = user.attributes
			hash[:client] = user.client ? user.client.name : nil
			respond({ status: 0, user: hash })
		else
			respond({ status: 1, error: "User #{params[:jive]} not found" })
		end
	end

	def get_all
		params[:count] = params[:count].empty? ? 100 : params[:count]
		params[:start] = params[:start].empty? ? 0 : params[:start]
		users = []
		User.all.limit(params[:count]).offset(params[:start]).each do |u|
			hash = u.attributes 
			hash[:client] = u.client ? u.client.name : nil
			users.push(hash)
		end
		respond({ status: 0, users: users })
	end

	private

		def update_user_client(params)
			u = User.find_by(jive_id: params[:jive_id])
			u.update_attributes(client: Client.find_by(name: params[:client]))
			return { status: 0, message: "Client Updated" }
		end

		def parse_user(params)
			if params[:client] != "undefined" && !params[:client].blank?
				client_id = Client.find_by(name: params[:client]).id
			else
				client_id = 0
			end
			return {client_id: client_id, jive_id: params[:jive_id], employee_id: params[:employee_id], name: params[:name]}	
		end

end
