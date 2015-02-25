require "Bunchball"

desc "Login to Bunchball"
task bb_login: :environment do
	bb = Bunchball.new
	bb.login
end

desc "Get User Points balance"
task bb_get_balance: :environment do
	bb = Bunchball.new
	bb.getUserPointsBalance('3170083')
end