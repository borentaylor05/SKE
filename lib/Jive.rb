class Jive
  include HTTParty
  require 'Auth'
  format :json
  @@current = ENV['SKE_URL']
  @@dev_url = "http://localhost:8080/api/core/v3"
  @@social = "https://social.teletech.com/api/core/v3"
  @@fairpoint = "https://fairfaqs.jiveon.com/api/core/v3"
  @@ww_coaches = "https://weightwatchers.jiveon.com/api/core/v3"

#  def initialize(base_url, auth_hash)
#    @base_url = base_url
#    @auth_hash = auth_hash
#  end
  
  def self.current
    @@current
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
    json = self.get(url, :basic_auth => auth).body
    self.clean(json)
  end

  def self.people_search(name)
    Jive.grab("#{Jive.social}/search/people?filter=search(#{name.gsub(/\s+/, "")})", Auth.social)
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
    json = self.put(url, options).parsed_response
  #  self.clean(json)
  end

  def self.remove(url, auth)
    headers 'Content-Type' => 'application/json'
    json = self.delete(url, :basic_auth => auth)
  end

  def self.create(url, params, auth)
    puts url
    headers 'Content-Type' => 'application/json'
    options = { body: params.to_json, basic_auth: auth }
    json = self.post(url, options).parsed_response
  end

  def self.clean(json)
    return JSON.parse(json.gsub!(/throw [^;]*;/, ''))
  end

  def self.getTags(relative_url, auth)
    json = self.grab(relative_url, auth)
    return json["tags"]
  end
end