require "Bunchball"
require "Jive2"

desc "Login to Bunchball"
task bb_login: :environment do
	bb = Bunchball.new
	bb.login
end

task get_mission: :environment do 
	bb = Bunchball.new('98086')
	puts bb.get_mission("2 Days of Attendance")
end

desc "Get User Points balance"
task bb_get_balance: :environment do
	bb = Bunchball.new('101052')
	resp = bb.get('user.getPointsBalance')
	puts resp
end

desc "Get leaderboard from set of user IDs (Oracle IDs)"
task leaderboard: :environment do 
	@test_users = %w{  }
	bb = Bunchball.new('98086')
	bb.get_leaders(@test_users)
end

task group_test: :environment do 
	bb = Bunchball.new('98086')
	puts bb.get("site.getPointsLeaders&groupName=Telstra Agents&duration=ALLTIME&returnCount=100")
	#puts bb.get("group.getUsers&groupName=Telstra GA&returnCount=100")
end

task add_to_group: :environment do 
	bb = Bunchball.new('98086')
	jive = Jive2.new('social')
	users = [20268370, 2058883, 2065398, 2071982, 2075725, 2077720, 2099200, 2114029, 2119372]
	users.each do |user|
		resp = jive.grab("/people/username/#{user}")
		if resp["id"]
			bb.add_user_to_group('Telstra Training Demo', resp["id"])
		else
			puts "User #{user} not found."
		end
	end
end

task get_group_users: :environment do 
	bb = Bunchball.new('98086')
	puts bb.get_group_users('Telstra Agents')
end

task add_user: :environment do 
	bb = Bunchball.new('98086')
	puts bb.add_user_to_group('Telstra Agents', '101211')
end

task mission_test: :environment do 
	bb = Bunchball.new('98086')
	puts bb.get_mission('1 Day of Attendance')
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
		one: ['1 Day of Attendance', '1st Day Assessment', '1st Day QA'],
		two: ['2 Days of Attendance', '2nd Day Assessment', '2nd Day QA'],
		three: ['3 Days of Attendance', '3rd Day Assessment', '3rd Day QA']
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
		CSV.foreach('telstra_day_eight.csv', headers: true) do |row| 
			if row[0]
				if row[1].to_i >= goals[:qa]
					puts "trying #{row[0]}" 
					puts bb.complete_mission(row[0].strip, "1st Day QA")
				end
				if row[2].to_i >= goals[:qa]
					puts "trying #{row[0]}" 
					puts bb.complete_mission(row[0].strip, "2nd Day QA")
				end
				if row[3].to_i >= goals[:qa]
					puts "trying #{row[0]}" 
					puts bb.complete_mission(row[0].strip, "3rd Day QA")
				end
				if row[4].to_i >= goals[:assessment]
					puts "trying #{row[0]}" 
					puts bb.complete_mission(row[0].strip, "1st Day Assessment")
				end
				if row[5].to_i >= goals[:assessment]
					puts "trying #{row[0]}" 
					puts bb.complete_mission(row[0].strip, "2nd Day Assessment")
				end
				if row[6].to_i >= goals[:assessment]
					puts "trying #{row[0]}" 
					puts bb.complete_mission(row[0].strip, "3rd Day Assessment")
				end
				if row[7].to_i >= goals[:assessment]
					puts "trying #{row[0]}" 
					puts bb.complete_mission(row[0].strip, "Final Assessment")
				end
				if row[7].to_i >= 100
					puts "trying #{row[0]}" 
					puts bb.complete_mission(row[0].strip, "Perfect score on Assessment")
				end
				if row[8].to_i >= 20
					puts "trying #{row[0]}" 
					puts bb.complete_mission(row[0].strip, "1 Day of Attendance")
				end
				if row[9].to_i >= 20
					puts "trying #{row[0]}"
					puts bb.complete_mission(row[0].strip, "2 Days of Attendance")
				end
				if row[10].to_i >= 20
					puts "trying #{row[0]}"
					puts bb.complete_mission(row[0].strip, "3 Days of Attendance")
				end
				if row[11].to_i >= 20
					puts "trying #{row[0]}"
					puts bb.complete_mission(row[0].strip, "4 Days of Attendance")
				end
				if row[12].to_i >= goals[:qa]
					puts "trying #{row[0]}"
					puts bb.complete_mission(row[0].strip, "4th Day QA")
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




