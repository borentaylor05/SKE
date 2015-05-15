require "Bunchball"

desc "Login to Bunchball"
task bb_login: :environment do
	bb = Bunchball.new
	bb.login
end

desc "Get User Points balance"
task bb_get_balance: :environment do
	bb = Bunchball.new('98086')
	resp = bb.get('site.getPointsLeaders&returnCount=100')
	puts resp
end

desc "Get leaderboard from set of user IDs (Oracle IDs)"
task leaderboard: :environment do 
	@test_users = %w{  }
	bb = Bunchball.new('98086')
	bb.get_leaders(@test_users)
end

task action: :environment do 
	bb = Bunchball.new('98086')
	puts bb.log_action('PollEvent-CREATED')
end

task folder_test: :environment do 
	bb = Bunchball.new('98086')
	puts bb.get_missions('TaylorTest')
end

task add_to_group: :environment do 
	bb = Bunchball.new('98086')
	puts bb.add_user_to_group('TestGroup', '98086')
end

task get_group_users: :environment do 
	bb = Bunchball.new('98086')
	puts bb.get_group_users('TelstraAllUsers')
end
