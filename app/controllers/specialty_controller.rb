class SpecialtyController < ApplicationController
	skip_before_action :verify_authenticity_token

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

	def add_specialties
		user = User.find_by(jive_id: params[:user].to_i)
		specialties = JSON.parse(params[:specialties])
		specialties.each do |s|
			spec = Specialty.find_by(name: s["name"])
			# if not already a specialty and attached == true
			if !user.specialties.include?(spec) && s["attached"] 
				user.specialties << spec # add specialty
			# if prev specialty and not attached now, delete association
			elsif user.specialties.include?(spec) && !s["attached"] 
				user.specialties.delete(spec) # delete association
			end
		end
		respond({specs: user.specialties})
	end

end
