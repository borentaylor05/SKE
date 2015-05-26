require "Bunchball"
require "Jive2"

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

task group_test: :environment do 
	bb = Bunchball.new('98086')
	puts bb.get("site.getPointsLeaders&groupName=Telstra Agents&duration=ALLTIME&returnCount=100")
	#puts bb.get("group.getUsers&groupName=Telstra GA&returnCount=100")
end

task add_to_group: :environment do 
	bb = Bunchball.new('98086')
	jive = Jive2.new('social')
	CSV.foreach("telstra_roster_051515.csv", headers: true) do |row|
		resp = jive.grab("/people/username/#{row[3]}")
		if resp["id"]
			case row[6]
			when "NA"
				puts "Added to GA - #{bb.add_user_to_group('Telstra Agents', resp["id"])}"
			when "Telstra Cebu Consumer"
				puts "Added to Agents - #{bb.add_user_to_group('Telstra GA', resp["id"])}"
			end
		else
			puts "User #{row[3]} not found."
		end
	end
end

task get_group_users: :environment do 
	bb = Bunchball.new('98086')
	puts bb.get_group_users('TelstraAllUsers')
end

task add_user: :environment do 
	bb = Bunchball.new('98086')
	puts bb.add_user_to_group('Telstra Agents', '101211')
end

task :complete_missions_telstra, [:day] => :environment do |t,args|
	bb = Bunchball.new('98086')
	cur_missions = nil
	goals = {
		assessment: 80,
		qa: 85,
		attendance: 20
	}
	missions = {
		one: ['1st Day Assessment', '1st Day Attendance', '1st Day QA'],
		two: ['2nd Day Assessment', '2nd Day Attendance', '2nd Day QA'],
		three: ['3rd Day Assessment', '3rd Day Attendance', '3rd Day QA']
	}
	if args[:day]
		case args[:day]
		when 'one'
			cur_missions = missions[:one]
		when 'two'
			cur_missions = missions[:two]
		when 'three'
			cur_missions = missions[:three]
		end 
		CSV.foreach('filename', headers: true) do |row| 
			if row[0]
				if row[1].to_i >= goals[:qa]
					bb.complete_mission(row[0].trim, cur_missions[2])
				end
				if row[2].to_i >= goals[:assessment]
					bb.complete_mission(row[0].trim, cur_missions[0])
				end
				if row[3].to_i >= goals[:attendance]
					bb.complete_mission(row[0].trim, cur_missions[1])
				end
			else
				puts "First column is empty."
				break
			end
		end
	else
		puts "You must specify a day"
	end
	# bb.get_missions('TaylorTest').to_json
	# puts bb.complete_mission('3170083', 'Test Challenge')
end



