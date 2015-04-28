# require 'Auth'
# require 'Util'
# # require 'HTTParty'

# class Jive2

# 	def initialize(instance)
# 		case instance
# 		when 'dev'
# 			@url = "http://localhost:8080/api/core/v3"
# 			@auth = Auth.dev
# 		when 'social'
# 			@url = "https://social.teletech.com/api/core/v3"
# 			@auth = Auth.social
# 		end
# 	end

# 	def get(resource)
# 	    json = HTTParty.get("#{@url}#{resource}", :basic_auth => @auth).body
# 	    if json 
# 	      clean(json)
# 	    else
# 	      puts json
# 	    end
# 	end

# 	def update(resource, params)
# 		#  puts url
# 		options = { body: params.to_json, basic_auth: @auth }
# 		return HTTParty.put("#{@url}#{@resource}", options, headers: {'Content-Type' => 'application/json'})
# 	end

# 	def delete(resource)
# 		json = HTTParty.delete("#{@url}#{resource}", basic_auth: @auth, headers: {'Content-Type' => 'application/json'})
# 	end

# 	def clean(json)
#         return JSON.parse(json.gsub!(/throw [^;]*;/, ''))
#     end

# 	def people_search(name)
#     	grab("#{@url}/search/people?filter=search(#{name.gsub(/\s+/, ",")})", @auth)
#   	end

# end