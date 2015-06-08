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
		@user_template = {
		    emails: [ {
		      value: "",
		      type: "work",
		      primary: true,
		      jive_label: "Email"
		    } ],
		    jive: {
		      password: "",
		      username: ""
		    },
		    name: {
		      familyName: "",
		      givenName: ""
		    }
		}
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

   def create_user(u, to_db)
      template = @user_template
      template[:emails][0][:value] = u[:email]
      template[:jive][:password] = "Welcome1"
      template[:jive][:username] = u[:oracle_id]
      template[:name][:givenName] = u[:first_name]
      template[:name][:familyName] = u[:last_name]
      resp = create("/people", template)
      if resp and resp["error"]
        eUser = User.find_by(employee_id: u[:oracle_id])
        if eUser
          json = grab("/people/username/#{u[:oracle_id]}")
          if json["id"] 
            if eUser.jive_id == 0
              eUser.update_attributes(jive_id: json["id"])
            end
            u[:jive_id] = eUser.jive_id
            if update_user_everywhere(json, u)
              return true
            else
              Rails.logger.info "ERROR - user #{u[:oracle_id]} could not be saved in db."
              return false
            end
          else
            Rails.logger.info("NOJIVEUSER -- #{u[:oracle_id]}")
          end
        else          
           Rails.logger.info "ERROR (#{u[:oracle_id]}) --------------> #{resp["error"]}"
          return false
        end
      elsif resp and resp["id"]
        u[:jive_id] = resp["id"]
        if to_db
          if Util.create_or_update_from_csv(u)
            Rails.logger.info "Created in Both:  #{resp["id"]}"
            return true
          else
            Rails.logger.info "Error: #{u[:first_name]} #{u[:last_name]}"
            return false
          end
        else
          Rails.logger.info Rails.logger.info "Created in Jive:  #{u[:oracle_id]}"
          return false
        end
        # if to_bb_group
        #   bb = Bunchball.new('98086')
        #   Rails.logger.info bb.add_user_to_group(to_bb_group, u[:jive_id])
        # end
      end
    end

end