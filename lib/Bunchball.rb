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
		puts url
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

	def add_user_to_group(group, user_id)
		return get("site.addUsersToGroup&groupName=#{group}&userIds=#{user_id}")
	end

	def get_group_users(group)
		return get("group.getUsers&groupName=#{group}&returnCount=100")
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

end

# nitroAPI = NitroAPISample.new
#nitroAPI.login
#nitroAPI.logAction
#nitroAPI.getUserPointsBalance
#nitroAPI.getActionLeaders



