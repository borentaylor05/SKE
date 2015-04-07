class GamificationController < ApplicationController
	require 'Bunchball'
	skip_before_action :verify_authenticity_token
	before_action :cors_set_access_control_headers

	def leaderboard
		@test_users = %w{ 3170083 3151641 3151232 3149422 2121597 2124496 3130922 3131893 3108626 }
		bb = Bunchball.new('3170083')
		leaders = bb.get_leaders(@test_users)
		respond({ status: 0, leaders: leaders })
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

end
