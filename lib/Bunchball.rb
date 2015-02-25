require 'digest/md5'
require 'rexml/document'

class Bunchball
	include HTTParty
	
	# Constants
	CRITERIA_MAX = "MAX";
	CRITERIA_CREDITS = "credits";
	POINT_CATEGORY_ALL = "all";
	TAGS_OPERATOR_OR = "OR";   

       def initialize
	       # Required Parameters
	       @baseURL = "https://solutions.nitro.bunchball.net/nitro/json"
	       @secretKey = "6c5d3cb1dcea4cf4b88f33b9c328264d"                # Use your secretKey to connect to the API
	       @apiKey = "5c4b9534bf9d460994b35f648ba63caa"                   # Use your apiKey to connect to the API
	       @userName = "3170083"
	       @actionTag = "NewChanllenge"
	       @value = "10"
	       @sessionKey = login
	end
	       
#   Method for constructing a signature
	def getSignature
	  time = Time.now.gmtime.to_i.to_s()
      unencryptedSignature = "#{@apiKey}#{@secretKey}#{time}#{@userName}"
	  return Digest::MD5.hexdigest(unencryptedSignature + unencryptedSignature.length.to_s())
	end

	def get(url)
		puts url
		return JSON.parse(HTTParty.get(url).body, symbolize_names: true)
	end
	
	def login
	       	ts = Time.now.gmtime.to_i.to_s()
	       	request = "#{@baseURL}?method=user.login&apiKey=#{@apiKey}&userId=#{@userName}&ts=#{ts}&sig=#{getSignature}";
			hash = get(request)
	       	@sessionKey = hash[:Nitro][:Login][:sessionKey]
	    #	puts @sessionKey
	end
	
	def logAction
	       sessionKey = @sessionKey
	       request = @baseURL + "method=user.logAction" + "&sessionKey=" + sessionKey + "&userId="+ @userName + "&tags=" + @actionTag + "&value=" + @value               
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
	
	def getUserPointsBalance(user)
	       login # sets valid session key
	       request = "#{@baseURL}?method=user.getPointsBalance&sessionKey=#{@sessionKey}&userId=#{user}"
	       puts "Getting balance for: #{user}..."
	       resp = get(request)
	       puts resp
	end
	
	def getActionLeaders
	       sessionKey = @sessionKey
	       actionTag = @actionTag
	       @userValue = "NA "
	       @userId = "NA "
	       request = @baseURL + "method=site.getActionLeaders" + "&sessionKey=" + @sessionKey + "&tags=" + @actionTag + "&tagsOperator=" + TAGS_OPERATOR_OR + "&criteria=" + CRITERIA_MAX + "&returnCount=" + @value
	       print "Getting Action Leaders...\n";
	       xml_data = Net::HTTP.get_response(URI.parse(request)).body
	       doc = REXML::Document.new(xml_data)             
	       doc.elements.each('Nitro/actions/Action') do |ele|
	               @userId = ele.attributes['userId']
	               @userValue = ele.attributes['value']
	       end
	        print @userId + "\t"
	        print @userValue + "\n"
	end
end

# nitroAPI = NitroAPISample.new
#nitroAPI.login
#nitroAPI.logAction
#nitroAPI.getUserPointsBalance
#nitroAPI.getActionLeaders



