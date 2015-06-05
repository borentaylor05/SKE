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
		@options[:basic_auth] = @auth
		@options[:headers] = {'Content-Type' => 'application/json'}
	end

	def test_grab(url)
		return HTTParty.get("#{url}", @options).body
	end

	def grab(resource)
	    json = HTTParty.get("#{@url}#{resource}", @options).body
	    if json 
	      clean(json)
	    else
	      puts json
	    end
	end

	def update(resource, params)
		#  puts url
		@options[:body] = params.to_json
		@options = { body: params.to_json, basic_auth: @auth }
		return HTTParty.put("#{@url}#{@resource}", @options)
	end

	def create(resource, params)
        @options[:body] = params.to_json
        json = HTTParty.post("#{@url}#{resource}", @options).parsed_response
        return json
    end

	def remove(resource)
		json = HTTParty.delete("#{@url}#{resource}", @options)
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

  	def add_to_sec_group(group_id, jive_ids)
  		jive_ids.map! { |id| id = "#{@url}/people/#{id}" }
      	puts jive_ids
      	return self.create("/securityGroups/#{group_id}/members", jive_ids)
  	end

  	def update_user_everywhere(json, user)
	     json = Util.parse_profile(json, user)
	     json["emails"][0] = { value: user[:email], type: "work", jive_label: "Email", primary: true }
	     json["name"]['familyName'] = user[:last_name]
	     json["name"]["givenName"] = user[:first_name]
	     resp = update("/people/#{json["id"]}", json)
	     if resp["error"]
	      puts(resp)
	      return false
	    else
	      user[:jive_id] = json["id"]
	      if Util.create_or_update_from_csv(user)
	        return true
	      else
	        puts(resp)
	        return false
	      end
	    end
   end

end