require 'Auth'
require 'Util'

class Jive2

	include HTTParty
	http_proxy = ENV["PROXIMO_URL"] if ENV["PROXIMO_URL"]

	def initialize(instance)
		case instance
		when 'dev'
			@url = "http://localhost:8080/api/core/v3"
			@auth = Auth.dev
		when 'social'
			@url = "https://social.teletech.com/api/core/v3"
			@auth = Auth.social
		end
	end

	def grab(resource)
	    json = HTTParty.get("#{@url}#{resource}", :basic_auth => @auth).body
	    if json 
	      clean(json)
	    else
	      puts json
	    end
	end

	def update(resource, params)
		#  puts url
		options = { body: params.to_json, basic_auth: @auth }
		return HTTParty.put("#{@url}#{@resource}", options, headers: {'Content-Type' => 'application/json'})
	end

	def remove(resource)
		json = HTTParty.delete("#{@url}#{resource}", basic_auth: @auth, headers: {'Content-Type' => 'application/json'})
	end

	def clean(json)
		if json 
        	return JSON.parse(json.gsub!(/throw [^;]*;/, ''))
        else
        	return false
        end
    end

	def people_search(name)
    	grab("#{@url}/search/people?filter=search(#{name.gsub(/\s+/, ",")})", @auth)
  	end

end