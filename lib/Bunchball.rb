require 'digest/md5'
require 'Jive'
require 'Jive2'

class Bunchball
	include HTTParty  

   	def initialize(user)
       # Required Parameters
       @test_users = %w{  }
       @baseURL = "https://solutions.nitro.bunchball.net/nitro/json"
       @secretKey = "45b7f425bff64a0d8041437753fe7e60"                # Use your secretKey to connect to the API
       @apiKey = "814a39fc7e5f43118553997519f44f41"                   # Use your apiKey to connect to the API
       @user = user
       @sessionKey = login
       @url1 = "#{@baseURL}?method="
       @url2 = "&sessionKey=#{@sessionKey}&userId=#{@user}"
	end
	       
#   Method for constructing a signature
	def getSignature
	  time = Time.now.gmtime.to_i.to_s()
      unencryptedSignature = "#{@apiKey}#{@secretKey}#{time}#{@user}"
	  return Digest::MD5.hexdigest(unencryptedSignature + unencryptedSignature.length.to_s())
	end

	def get(method, json = false)
		url = URI.encode("#{@url1}#{method}#{@url2}")
		if json 
			return HTTParty.get(url).body
		else
			return JSON.parse(HTTParty.get(url).body, symbolize_names: true)
		end
	end
	
	def login
       	ts = Time.now.gmtime.to_i.to_s()
       	request = "#{@baseURL}?method=user.login&apiKey=#{@apiKey}&userId=#{@user}&ts=#{ts}&sig=#{getSignature}";
		hash = JSON.parse(HTTParty.get(request).body, symbolize_names: true)
       	@sessionKey = hash[:Nitro][:Login][:sessionKey]
	end

	def getUserRank
		return get "site.getPointsLeaders&withSurroundingUsers=true&userIds=#{@user}"
	end
	
	# users = employee IDs (Oracle IDs)
	def get_leaders(users)
		string = ""
		url = "site.getPointsLeaders&duration=ALLTIME&userIds="
		users.each { |u| string += "#{u}," }
		url = "#{url}#{string}"
		leaderboard = get(url)
		leaderboard[:Nitro][:leaders][:Leader].each do |person|
			j_user = Jive.grab("#{Jive.social}/people/username/#{person[:userId]}", Auth.social)
			person[:jive] = j_user
			person[:jive][:published] = DateTime.iso8601(j_user["published"]).strftime('%B %d, %Y')
		end
		return leaderboard
	end

	def get_missions(folder)
		return get("user.getChallengeProgress&folder=#{folder}")
	end

	def get_user_missions
		return get("site.getRecentChallenges&userIds=#{@user}")
	end

	def log_action(action)
		return get("user.logAction&tags=#{action}")
	end

	def get_mission(name)
		return get("user.getChallengeProgress&challengeName=#{name}&showOnlyTrophies=false")
	end

	def mission_exists?(name)
		# for some reason the API returns challenges == true when the challenge does not exist
		# it returns challenges[:Challeng] otherwise 
		return get_mission(name)[:Nitro][:challenges] != true
	end

	def add_user_to_group(group, user_id)
		return get("site.addUsersToGroup&groupName=#{group}&userIds=#{user_id}")
	end

	def get_group_users(group)
		return get("group.getUsers&groupName=#{group}&returnCount=100")
	end

	def set_preference(pref)
		return get("user.setPreference&userId=#{@user}&name=#{pref[:name]}&value=#{pref[:value]}")
	end

	def complete_mission(oracle_id, challenge)
		jive = Jive2.new('social')
		resp = jive.grab("/people/username/#{oracle_id}")
		if resp and resp["id"]
			url = URI.encode("#{@baseURL}?method=user.awardChallenge&sessionKey=#{@sessionKey}&userId=#{resp["id"]}&challenge=#{challenge}")
		else
			puts resp
		end
		return HTTParty.get(url).body
	end

	def parse_mlevel_report
		jive = Jive2.new('social')
		total_stars = current_user = max_stars = 0
		earned_badges = []
		current_mission = prev_mission = { name: "", stars: 0, user: 0 }
		count = 0
		CSV.foreach("mlevel_report.csv", headers: true) do |row|
			if row[0]
				current_mission = { name: "", stars: 0, user: 0 }				
				if row[4] != current_user	
					if total_stars >= 11
						earned_badges.push current_user
					end									
					total_stars = 0
					prev_mission = { name: "", stars: 0, user: 0 }
				end		

				current_mission[:user] = current_user = row[4]
				current_mission[:name] = row[10]
				current_mission[:stars] = row[18]

				if current_mission[:name] != prev_mission[:name]
					max_stars = 0
				end
				
				if current_mission[:user] == prev_mission[:user] and current_mission[:name] == prev_mission[:name]					
					if current_mission[:stars].to_i > prev_mission[:stars].to_i and current_mission[:stars].to_i > max_stars										
						total_stars += current_mission[:stars].to_i
						total_stars -= max_stars
						max_stars = current_mission[:stars].to_i							
					end
				elsif current_mission[:name] != prev_mission[:name]									
					total_stars += current_mission[:stars].to_i	
					max_stars = current_mission[:stars].to_i	
				end								
				prev_mission = current_mission										
			end
		end
	#	earned_badges.append(9999999)
		earned_badges.each do |user|
			bb.complete_mission(user, 'new zealand geo')			
		end
		m = Message.create!(
			user: User.find_by(jive_id: 9999999),
			text: "You have completed the mission 'New Zealand Geo' by gaining 11 stars in your mLevel training.",
			client: Client.find_by(name: 'fairfax'),
			urgent: false
		)
		m.send_message(earned_badges)
	end

end



