require 'Auth'
require 'Util'

class Jive2

	include HTTParty
	

	def initialize(instance)
		@proxy = URI(ENV["QUOTAGUARDSTATIC_URL"]) if ENV["QUOTAGUARDSTATIC_URL"]
		@options = {}
		if @proxy
			@options = {http_proxyaddr: @proxy.host,http_proxyport: @proxy.port, http_proxyuser: @proxy.user, http_proxypass: @proxy.password}
		end
		case instance
		when 'dev'
			@url = "http://localhost:8080/api/core/v3"
			@auth = Auth.dev
		when 'social'
			@url = "https://social.teletech.com/api/core/v3"
			@auth = Auth.social
		end
	end

	def test_grab(url)
		@options[:basic_auth] = @auth
		return HTTParty.get("#{url}", @options).body
	end

	def grab(resource)
		@options[:basic_auth] = @auth
	    json = HTTParty.get("#{@url}#{resource}", @options).body
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