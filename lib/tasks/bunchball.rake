require "Bunchball"

desc "Login to Bunchball"
task bb_login: :environment do
	bb = Bunchball.new
	bb.login
end

desc "Get User Points balance"
task bb_get_balance: :environment do
	bb = Bunchball.new('3170083')
	resp = bb.get('site.getPointsLeaders&returnCount=100')
	puts resp
end

desc "Get leaderboard from set of user IDs (Oracle IDs)"
task leaderboard: :environment do 
	@test_users = %w{ 3170083 3151641 3151232 3149422 2121597 2124496 3130922 3131893 3108626 }
	bb = Bunchball.new('3170083')
	bb.get_leaders(@test_users)
end

task action: :environment do 
	bb = Bunchball.new('3170083')
	puts bb.log_action('PollEvent-CREATED')
end