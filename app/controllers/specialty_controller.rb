class SpecialtyController < ApplicationController

	def get
		if !params.has_key?("client")
			response = { status: 0, message: "This request requires you to provide a client parameter" }
		else
			specialties = []
			if !params.has_key?("user")
				Specialty.where(client: Client.find_by(name: params[:client])).each do |s|
					spec = {
						name: s.name,
						attached: false
					}
					specialties.push(spec)
				end
			else
				u = User.find_by(jive_id: params[:user])	
				Specialty.where(client: Client.find_by(name: params[:client])).each do |s|
					spec = {
						name: s.name,
					}
					if u.specialties.include?(s)
						spec[:attached] = true
					else
						spec[:attached] = false
					end
					specialties.push(spec)
				end
			end
			response = specialties
		end	
		respond(response)
	end

	def add_specialty
		# add this tomorrow
	end

end
