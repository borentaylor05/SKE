class UserController < ApplicationController
	skip_before_action :verify_authenticity_token

	def create
		user = parse_user(params)
		if(User.find_by(jive_id: user[:jive_id]).blank?)
			u = User.new(jive_id: user[:jive_id], employee_id: user[:employee_id], client_id: user[:client_id])
			if u.valid?
				u.save
				response = { status: "User Created" }
			else
				response = { status: "Error: #{u.errors.full_messages}" }
			end
		else
			response = { status: "User Exists" }
		end
		respond_to do |format|
			format.any(:json, :html) { render json: response }
		end
	end

	private

		def parse_user(params)
			if params[:client] != "undefined"
				client_id = Client.find_by(name: params[:client]).id
			else
				client_id = 0
			end
			return {client_id: client_id, jive_id: params[:jive_id], employee_id: params[:employee_id]}	
		end

end
