require "Bunchball"
require "BunchballHelper"
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
	puts bb.get_group_users('Hyundai Agents')
end

# task add_user: :environment do 
# 	bb = Bunchball.new('98086')
# 	puts bb.add_user_to_group('Hyundai Agents', '101211')
# end

task mission_test: :environment do 
	bb = Bunchball.new('98086')
	puts bb.get_mission('1 Day of Attendance')
end

# task :complete_missions_telstra, [:day] => :environment do |t,args|
# 	bb = Bunchball.new('98086')
# 	cur_missions = nil
# 	goals = {
# 		perfectassessment: 100,
# 		assessment: 90,
# 		qa: 3,
# 		attendance: 1,
# 		ontimefirstday: 1,
# 		graduation: 1,
# 		empathy: 1,
# 		notes: 1,
# 		efficiency: 1,
# 		performer: 1,
# 		navigator: 1
# 	}
# 	if args[:day]
# 		case args[:day]
# 		when 'one'
# 			cur_missions = missions[:one]
# 		when 'two'
# 			cur_missions = missions[:two]
# 		when 'three'
# 			cur_missions = missions[:three]
# 		end 
# 		CSV.foreach('telstra_report.csv', headers: true) do |row| 
# 			if row[0]
# 				if row[1].to_i >= goals[:ontimefirstday]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "On time the first day (Hyundai) !")
# 				end
# 				if row[2].to_i >= goals[:qa]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Passing 1st QA Score(Hyundai)!")
# 				end
# 				if row[3].to_i >= goals[:qa]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Passing 2nd QA Score(Hyundai)!")
# 				end
# 				if row[4].to_i >= goals[:qa]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Passing 3rd QA Score(Hyundai)!")
# 				end
# 				if row[5].to_i >= goals[:qa]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Passing 4th QA Score(Hyundai)!")
# 				end
# 				if row[6].to_i >= goals[:qa]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Passing 5th QA Score(Hyundai)!")
# 				end
# 				if row[7].to_i >= goals[:qa]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Passing 6th QA Score(Hyundai)!")
# 				end
# 				if row[8].to_i >= goals[:assessment]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "90% on 1st Assessment!(Hyundai)!")
# 				end
# 				if row[9].to_i >= goals[:assessment]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "90% on 2nd Assessment!(Hyundai)!")
# 				end
# 				if row[10].to_i >= goals[:assessment]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "90% on 3rd Assessment!(Hyundai)!")
# 				end
# 				if row[11].to_i >= goals[:assessment]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "90% on 4th Assessment!(Hyundai)!")
# 				end
# 				if row[12].to_i >= goals[:assessment]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "90% on 5th Assessment!(Hyundai)!")
# 				end
# 				if row[13].to_i >= goals[:assessment]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "90% on 6th Assessment!(Hyundai)!")
# 				end
# 				if row[14].to_i >= goals[:perfectassessment]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Perfect Score on 1st Assessment (Hyundai)!")
# 				end
# 				if row[15].to_i >= goals[:perfectassessment]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Perfect Score on 2nd Assessment (Hyundai)!")
# 				end
# 				if row[16].to_i >= goals[:perfectassessment]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Perfect Score on 3rd Assessment (Hyundai)!")
# 				end
# 				if row[17].to_i >= goals[:perfectassessment]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Perfect Score on 4th Assessment (Hyundai)!")
# 				end
# 				if row[18].to_i >= goals[:perfectassessment]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Perfect Score on 5th Assessment (Hyundai)!")
# 				end
# 				if row[19].to_i >= goals[:perfectassessment]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Perfect Score on 6th Assessment (Hyundai)!")
# 				end
# 				if row[20].to_i >= goals[:attendance]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Perfect Attendence Week 1 (Hyundai)!")
# 				end
# 				if row[21].to_i >= goals[:attendance]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Perfect Attendence Week 2 (Hyundai)!")
# 				end
# 				if row[22].to_i >= goals[:attendance]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Perfect Attendence Week 3 (Hyundai)!")
# 				end
# 				if row[23].to_i >= goals[:attendance]
# 					puts "trying #{row[0]}"
# 					puts bb.complete_mission(row[0].strip, "Perfect Attendence Nesting Week (Hyundai)!")
# 				end
# 				if row[24].to_i >= goals[:graduation]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Graduation (Hyundai)!")
# 				end
# 				if row[25].to_i >= goals[:empathy]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Empathy Expert (Hyundai)!")
# 				end
# 				if row[26].to_i >= goals[:notes]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Top Notch Notes (Hyundai)!")
# 				end
# 				if row[27].to_i >= goals[:efficiency]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Efficiency Expert (Hyundai)!")
# 				end
# 				if row[28].to_i >= goals[:performer]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Top Performer (Hyundai)!")
# 				end
# 				if row[29].to_i >= goals[:navigator]
# 					puts "trying #{row[0]}" 
# 					puts bb.complete_mission(row[0].strip, "Skillful navigator (Hyundai)")
# 				end
# 			else
# 				puts "First column is empty."
# 				break
# 			end
# 		end
# 	else
# 		puts "You must specify a day"
# 	end
# 	# bb.get_missions('TaylorTest').to_json
# 	# puts bb.complete_mission('3170083', 'Test Challenge')
# end

task :gamify, [:filename, :kill_on_missing] => :environment do |t,args|
	kill_on_missing = args[:kill_on_missing] || 'kill'
	bb = Bunchball.new('98086')
	bbh = BunchballHelper.new
	goals = bbh.get_client_goals 'hyundai'
	missions = nil
	current_oracle = nil
	begin
		CSV.foreach(args[:filename]) do |row|
			if row[0]
				if $INPUT_LINE_NUMBER == 1
					# get missions from first line in file and store missions in an array
					# status[:missions] -> all missions in the first row
					# status[:errors] -> all missions missing from Bunchball
					status = bbh.check_missions(row)
					missions = status[:missions]					
					if !status[:errors].empty?
						# LOGGING
						puts 'ERROR: Killed due to missing Bunchball missions.' unless kill_on_missing == 'no_kill'
						puts 'The following missions do not exist in Bunchball:'
						puts status[:errors] { |e| puts e }
						break unless kill_on_missing == 'no_kill'
					end
				else
					row.each_with_index do |grade, i|
						if i == 0
							# save first column as oracle id
							current_oracle = grade.strip
						else
							mission = missions[i]
							puts "GRADE: #{grade.to_i} -- GOAL: #{bbh.get_goal(mission[:name], goals)}"
							if mission[:name] && mission[:exists] && grade.to_i >= bbh.get_goal(mission[:name], goals)
								puts "WOULD COMPLETE -- #{mission}"
							#	puts bb.complete_mission(current_oracle, mission[:name])
							elsif !mission
								# means script added missions for columns that do not exist
								break								
							end
						end
					end
				end
			end
		end
	rescue TypeError => e
		puts "ERROR: You must provide a file name and path. Correct usage:"
		puts " --- rake gamify['tmp/myfilename.csv']"
		puts "To ignore missing Bunchball missions, run:"
		puts " --- rake gamify['tmp/myfilename.csv', 'no_kill']"
	rescue Errno::ENOENT => e
		puts "ERROR: File #{args[:filename]} not found. Correct usage:"
		puts " --- rake gamify['tmp/myfilename.csv']"
		puts "Or to ignore missing Bunchball missions:"
		puts " --- rake gamify['tmp/myfilename.csv', 'no_kill']"
	end
end

task test_me: :environment do
	jive = Jive2.new('social')
	puts jive.grab("/people/username/3151232")
end


