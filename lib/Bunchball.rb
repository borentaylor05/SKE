require 'digest/md5'
require 'Jive'

class Bunchball
	include HTTParty  

   	def initialize(user)
       # Required Parameters
       @test_users = %w{ 3170083 3151641 3151232 ecampagna 3149422 2121597 2124496 williamcrosslin 3130922 3131893 3108626 }
       @baseURL = "https://solutions.nitro.bunchball.net/nitro/json"
       @secretKey = "6c5d3cb1dcea4cf4b88f33b9c328264d"                # Use your secretKey to connect to the API
       @apiKey = "5c4b9534bf9d460994b35f648ba63caa"                   # Use your apiKey to connect to the API
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
		url = "#{@url1}#{method}#{@url2}"
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
	
	def logAction
		sessionKey = @sessionKey
		request = @baseURL + "method=user.logAction" + "&sessionKey=" + sessionKey + "&userId="+ @user + "&tags=" + @actionTag + "&value=" + @value               
		print "Logging an action... \n";
		xml_data = Net::HTTP.get_response(URI.parse(request)).body              
		               doc = REXML::Document.new(xml_data)             
		doc.elements.each('Nitro') do |ele|
		       @response = ele.attributes['res']
		end
		print @response         
		if @response.eql? "ok"
		       print "logAction successful!\n"
		end     
	end

	def getUserRank
		return get "site.getPointsLeaders&withSurroundingUsers=true&userIds=#{@user}"
	end
	
	def get_leaders(users)
		string = ""
		url = "site.getPointsLeaders&duration=ALLTIME&userIds="
		users.each { |u| string += "#{u}," }
		url = "#{url}#{string}"
		leaderboard = get(url)
		leaderboard[:Nitro][:leaders][:Leader].each do |person|
			j_user = Jive.grab("#{Jive.social}/people/username/#{person[:userId]}", Jive.auth)
			person[:jive] = j_user
			person[:jive][:published] = DateTime.iso8601(j_user["published"]).strftime('%B %d, %Y')
		end
		return leaderboard
	end

	def get_missions(folder)
		return get("user.getChallengeProgress&folder=#{URI.encode(folder)}")
	end

	def get_user_missions
		return get("site.getRecentChallenges&userIds=#{@user}")
	end

	def log_action(action)
		return get("user.logAction&tags=#{action}")
	end

	def get_mission(name)
		return get("user.getChallengeProgress&challengeName=#{URI.encode(name)}")
	end

end

# nitroAPI = NitroAPISample.new
#nitroAPI.login
#nitroAPI.logAction
#nitroAPI.getUserPointsBalance
#nitroAPI.getActionLeaders



