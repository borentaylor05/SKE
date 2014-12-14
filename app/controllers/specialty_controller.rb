class SpecialtyController < ApplicationController

	def get
		if !params.has_key?(:client)
			response = { status: 0, message: "This request requires you to provide a client parameter" }
		else
			s = Specialty.where(client: Client.find_by(name: params[:client]))
		end	
		respond({})
	end

end
