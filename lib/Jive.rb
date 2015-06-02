class Jive
  include HTTParty
  require 'Auth'
  require 'Util'
  format :json
  @@new_url = "https://knowledge.jiveon.com/api/core/v3"
  @@dev_url = "http://localhost:8080/api/core/v3"
  @@social = "https://social.teletech.com/api/core/v3"
  @@fairpoint = "https://fairfaqs.jiveon.com/api/core/v3"
  @@ww_coaches = "https://weightwatchers.jiveon.com/api/core/v3"
  @@uat = "https://uat-social.teletech.com/api/core/v3"

  @@user_template = {
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

#  def initialize(base_url, auth_hash)
#    @base_url = base_url
#    @auth_hash = auth_hash
#  end
  
  def self.new_url
    @@new_url
  end

  def self.user_template
    @@user_template
  end

  def self.uat 
    @@uat
  end

  def self.ww_coaches
    @@ww_coaches
  end

  def self.social
    @@social
  end

  def self.dev_url
    @@dev_url
  end

  def self.fairpoint_url
    @@fairpoint
  end

  def self.auth
   Auth.social
  end

  def self.grab(url, auth)
    puts url
    json = self.get(url, :basic_auth => auth).body
    if json 
      self.clean(json)
    else
      puts json
    end
  end

  def self.people_search(name, jive)
    Jive.grab("#{jive[:url]}/search/people?filter=search(#{name.gsub(/\s+/, ",")})", jive[:auth])
  end

  def self.get_docs_from_place(instance, auth, placeID)
    place_url = "#{instance}/places/#{placeID}"
    json = self.grab(place_url, auth)
    docs_url = json["resources"]["contents"]["ref"]
    startIndex = 0
    json = self.grab("#{docs_url}&count=100&startIndex=#{startIndex}", auth)
    docs = []
    while !json.nil? and json["list"].count != 0
      begin
        json["list"].each do |doc|
          if !docs.include?(doc["resources"]["self"]["ref"])
            docs.push(doc["resources"]["self"]["ref"])
          end
        end
        startIndex = startIndex + 100
        puts "#{docs_url}&count=100&startIndex=#{startIndex}"
        json = self.grab("#{docs_url}&count=100&startIndex=#{startIndex}", auth)
      rescue URI::InvalidURIError
        break
      rescue TypeError
        break
      rescue Net::ReadTimeout
        break
      end
    end
    return docs
  end

  # needs stream ID, docs urls array and Jive authentication object
  def self.add_to_stream(streamID, objectUrls, auth)
    url = "#{Jive.social}/streams/#{streamID}/associations"
    resp = self.create(url, objectUrls, auth)
    puts resp
  end

  def self.fix_backwards_name(name)
    parts = name.split(",")
    return "#{parts[1].strip} #{parts[0].strip}"
  end

  def self.update(url, params, auth)
  #  puts url
    headers 'Content-Type' => 'application/json'
    options = { body: params.to_json, basic_auth: auth }
    return self.put(url, options)
  end

  def self.remove(url, auth)
    headers 'Content-Type' => 'application/json'
    json = self.delete(url, :basic_auth => auth)
  end

    def self.create(url, params, auth)
        headers 'Content-Type' => 'application/json'
        options = { body: params.to_json, basic_auth: auth }
        json = self.post(url, options).parsed_response
        return json
    end

    def self.clean(json)
        return JSON.parse(json.gsub!(/throw [^;]*;/, ''))
    end

    def self.getTags(relative_url, auth)
        json = self.grab(relative_url, auth)
        return json["tags"]
    end

    def self.humanify_doc(doc)
        json = self.grab("#{Jive.dev_url}/contents?filter=entityDescriptor(102,#{self.parseDocNum(doc)})", Auth.dev)
        puts json["list"][0]["content"]["text"]
    end

    def self.parseDocNum(doc)
        return doc[4..-1]
    end

    # NOTE: this does not perform PUT, only returns updated json object
    #         :jive -> hash{ :auth, :url }
    def self.change_username_to_oracle_id(jive_id, oracle_id, jive)
      if oracle_id
         json = self.grab("#{jive[:url]}/people/#{jive_id}", jive[:auth])
         json["jive"]["username"] = oracle_id
         return json
      else
         return false
      end
    end

   # Params: :json -> jive user from API call
   #         :user -> hash created from CSV row (user[:jive_id] is from API call)   
   #             { :first_name, :last_name, :email, :oracle_id, :job_title, :client, :lob }
   #         :jive -> hash{ :auth, :url }              
   def self.update_user_with_csv_data(json, user, jive)
      if Util.csv_user_is_valid?(user)
         json = Util.parse_profile(json, user)
         json["emails"][0] = { value: user[:email], type: "work", jive_label: "Email", primary: true }
         json["name"]['familyName'] = user[:last_name]
         json["name"]["givenName"] = user[:first_name]
         return self.update("#{jive[:url]}/people/#{user[:jive_id]}", json, jive[:auth])
      else
         puts "Invalid user: #{user}"
      end
   end

   # Params: :json -> jive user from API call
   #         :user -> hash created from CSV row (user[:jive_id] is from API call)   
   #             { :first_name, :last_name, :email, :oracle_id, :job_title, :client, :lob }
   #         :jive -> hash{ :auth, :url }              
   def self.update_user_everywhere(json, user, jive)
         json = Util.parse_profile(json, user)
         json["emails"][0] = { value: user[:email], type: "work", jive_label: "Email", primary: true }
         json["name"]['familyName'] = user[:last_name]
         json["name"]["givenName"] = user[:first_name]
         resp = self.update("#{jive[:url]}/people/#{json["id"]}", json, jive[:auth])
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

   def self.add_to_sec_group(group_id, jive_ids)
      jive = { url: Jive.social, auth: Auth.social }
      jive_ids.map! { |id| id = "#{jive[:url]}/people/#{id}" }
      puts jive_ids
      return self.create("#{jive[:url]}/securityGroups/#{group_id}/members", jive_ids, jive[:auth])
   end

    # hash -> :email, :password, :employee_id, :job_title, :client, :location, :lob, :first_name, :last_name
    def self.new_person(hash)
        return {
            emails: [ {
                value: hash[:email],
                type: "work",
                primary: true,
                jive_label: "Email"
            } ],
            jive: {
                password: hash[:password],
                username: hash[:employee_id],
                job_title: hash[:job_title],
                client: hash[:client],
                location: hash[:location], # country code (APAC for now)
                lob: hash[:lob] # 
            },
            name: {
                familyName: hash[:last_name],
                givenName: hash[:first_name]
            }
        }
    end

    # u -> User hash from CSV
    # to_db -> boolean that determines whether to save to env db
    def self.create_user(u, to_db)
      jive = { url: Jive.social, auth: Auth.social }
      template = self.user_template
      template[:emails][0][:value] = u[:email]
      template[:jive][:password] = "Welcome1"
      template[:jive][:username] = u[:oracle_id]
      template[:name][:givenName] = u[:first_name]
      template[:name][:familyName] = u[:last_name]
      resp = Jive.create("#{jive[:url]}/people", template, jive[:auth])
      if resp["error"]
        eUser = User.find_by(employee_id: u[:oracle_id])
        if eUser
          u[:jive_id] = eUser.jive_id
          json = self.grab("#{jive[:url]}/people/#{u[:jive_id]}", jive[:auth])
          if self.update_user_everywhere(json, u, jive)
            return true
          else
            Rails.logger.info "ERROR - user #{u[:oracle_id]} could not be saved in db."
            return false
          end
        else          
           Rails.logger.info "ERROR (#{u[:oracle_id]}) --------------> #{resp["error"]}"
          return false
        end
      elsif resp["id"]
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

    def self.check_user(oracle_id)
      jive = { url: Jive.social, auth: Auth.social }
      resp = Jive.grab("#{jive[:url]}/people/username/#{oracle_id}", jive[:auth])
      if resp["id"]
        puts "Created #{oracle_id}"
      else
        puts "#{oracle_id} ---> #{resp[:error]}"
      end
    end

    # hash -> :email, :password, :employee_id, :job_title, :client, :location, :lob, :first_name, :last_name
    def self.new_jive_person(hash)
        return {
            emails: [ {
                value: hash[:email],
                type: "work",
                primary: true,
                jive_label: "Email"
            } ],
            jive: {
                password: hash[:password],
                username: hash[:employee_id],
                profile: [
                  {
                    jive_label: "Title",
                    value: hash[:title]
                  },
                  {
                    jive_label: "Client",
                    value: hash[:client].titleize
                  },
                  {
                    jive_label: "TeleTech Location",
                    value: hash[:location]
                  },
                  {
                    jive_label: "LOB",
                    value: hash[:lob]
                  },
                  {
                    jive_label: "Oracle ID",
                    value: hash[:employee_id]
                  }
                ]
                 
            },
            name: {
                familyName: hash[:last_name],
                givenName: hash[:first_name]
            }
        }
    end
end