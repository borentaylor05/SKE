class UserController < ApplicationController
	include ActionView::Helpers::DateHelper
	 skip_before_action :verify_authenticity_token
	 before_action :cors_set_access_control_headers
	 after_action :allow_iframe
	
	# see if user is in db
	# Params: :jive_id
	def check_init
		u = User.find_by(jive_id: params[:user])
		if u and u.jive_id > 0
			respond({ status: 0, message: "User exists", user: u, client: u.client })
		elsif u
			if u.jive_id > 0
				respond({ status: 1, error: "User is not in DB." })
			else
				respond({ status: 1, error: "User needs a Jive ID." })
			end
		else
			respond({ status: 1, error: "User not found." })
		end
	end

	# Params: :term, e.g. /users/search?term=seachforthisterm
	def search
		users = []
		if !params.has_key?("term") or params[:term].empty?
			respond({ status: 1, error: "You must provide a term to search for" })
		else
			User.contains(params[:term]).each do |u|
				hash = u.attributes 
				hash[:client] = u.client ? u.client.name : nil
				users.push(hash)
			end
			respond({ status: 0, users: users })
		end
	end

	def check_pending
		u = User.find_by(jive_id: params[:jive])
		if u
			respond({ status: 0, pending: u.pending_urgent })
		else
			respond({ status: 1, error: "User #{params[:jive]} not found. " })
		end
	end

	# Params: :jive_id, :employee_id, :name, :client(as client name)
	def create
		if(request.method == "OPTIONS")
			respond({status: 1})
		elsif request.method == "POST"
			user = parse_user(params)
			u = User.find_by(jive_id: user[:jive_id])
			if !u
				u = User.new(jive_id: user[:jive_id], 
							 employee_id: user[:employee_id], 
							 client_id: user[:client_id],
							 name: user[:name]	
							 )
				if u.valid?
					u.save
					response = { status: 0, message: "User Created", user: u }
				else
					response = { status: 1, error: "Error: #{u.errors.full_messages}" }
				end
			else
				if !params[:client].blank?
					u = update_user_client(params)[:user]
				end
				response = { status: 0, message: "User Exists.", user: u }
			end
			respond(response)
		end
	end

	# Params: :jive_id, :client -> name of client
	def update_client
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			respond(update_user_client(params))
		end
	end

	def get
		user = User.find_by(jive_id: params[:jive])
		if user and params[:jive] and params[:jive].to_i > 0
			hash = user.attributes
			hash[:client] = user.client ? user.client.name : nil
			respond({ status: 0, user: hash })
		else
			respond({ status: 1, error: "User #{params[:jive]} not found" })
		end
	end

	def new
		
	end

	# Params :count(default = 50), :start(default = 0)
	def get_all
		if !params.has_key?("count") or params[:count].empty?
			params[:count]= 50
		end
		if !params.has_key?("start") or params[:start].empty? 
			params[:start] = 0 
		end
		users = []
		User.all.limit(params[:count]).offset(params[:start]).each do |u|
			hash = u.attributes 
			hash[:client] = u.client ? u.client.name : nil
			users.push(hash)
		end
		respond({ status: 0, users: users, start: params[:start] })
	end

	private

		def update_user_client(params)
			u = User.find_by(jive_id: params[:jive_id])
			if u
				client = Client.find_by(name: params[:client])
				if client 
					u.update_attributes(client: client)
					return { status: 0, message: "Client Updated", user: u }
				else
					return { status: 1, error: "No client by name #{params[:client]}" }
				end
			else
				return { status: 1, error: "User not found" }
			end
			
		end

		# this is bad
		def parse_user(params)
			if params[:client] && params[:client] != "undefined" && !params[:client].blank?
				client_id = Client.find_by(name: params[:client]).id
			else
				client = User.find_by(jive_id: params[:jive_id]).client
				if client
					client_id = client.id
				else
					client_id = nil
				end
			end
			return {client_id: client_id, jive_id: params[:jive_id], employee_id: params[:employee_id], name: params[:name]}	
		end

end
