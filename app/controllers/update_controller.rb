class UpdateController < ApplicationController
	skip_before_action :verify_authenticity_token

	def create
		update = Update.new(
			user: User.find_by(jive_id: params[:jive_id]),
			text: params[:text],
			client: Client.find_by(name: params[:client]),
			title: params[:title]
		)
		p = Post.new(user: User.find_by(jive_id: params[:jive_id]), client: Client.find_by(name: params[:client]))
		p.action = update
		if update.valid? && p.valid?
			update.save
			p.save
			response = { status: 1 }
		else	
			response = { status: 0, error: "UPDATE: #{update.errors.full_messages} POST: p.errors.full_messages" }
		end
		respond(response)
	end

end
