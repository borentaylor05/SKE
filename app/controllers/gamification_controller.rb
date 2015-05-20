class GamificationController < ApplicationController
	require 'Bunchball'
	skip_before_action :verify_authenticity_token
	before_action :cors_set_access_control_headers

	def leaderboard
		if params.has_key?("user")
			user = User.find_by(jive_id: params[:user])
			if user 					
				respond({ status: 0, leaders: user.leaderboard, user: user })
			else
				respond({ status: 1, error: "Jive ID #{params[:user]} not found." })
			end
		else
			respond({ status: 1, error: "No user parameter." })
		end
	end

	def missions
		bb = Bunchball.new('3170083')
		missions = bb.get_missions('Easy (Blue)')
		respond({ status: 0, missions: missions })
	end

	def user_missions
		bb = Bunchball.new(params[:username])
		missions = bb.get_user_missions
		respond({ status: 0, missions: missions })
	end

	def top_three
		if params.has_key?("jive_id")
			user = User.find_by(jive_id: params[:jive_id])
			if user
				respond({ status: 0, missions: user.top_three_missions })
			else
				respond({ status: 1, error: "User with jive ID #{params[:jive_id]} not found." })	
			end
		else
			respond({ status: 1, error: "You must specify a user (Jive ID) with this request." })
		end	
	end

end
