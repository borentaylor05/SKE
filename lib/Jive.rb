class Jive
  include HTTParty
  require 'Auth'
  format :json
  @@dev_url = "http://localhost:8080/api/core/v3"
  @@social = "https://social.teletech.com/api/core/v3"
#  def initialize(base_url, auth_hash)
#    @base_url = base_url
#    @auth_hash = auth_hash
#  end
  
  def self.social
    @@social
  end

  def self.dev_url
    @@dev_url
  end

  def self.auth
   Auth.social
  end

  def self.grab(relative_url, auth)
    json = self.get(relative_url, :basic_auth => auth).body
    self.clean(json)
  end

  def self.update(url, params, auth)
    puts url
    headers 'Content-Type' => 'application/json'
    options = { body: params.to_json, basic_auth: auth }
    json = self.put(url, options).parsed_response
  #  self.clean(json)
  end

  def self.clean(json)
    return JSON.parse(json.gsub!(/throw [^;]*;/, ''))
  end

  def self.getTags(relative_url, auth)
    json = self.grab(relative_url, auth)
    return json["tags"]
  end
end