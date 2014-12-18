class Jive
  include HTTParty
  format :json
  @@dev_url = "http://localhost:8080/api/core/v3"
  @@social_auth = {:username => "3170083", :password => "!QAZ2wsx"}
  @@wwc_auth = {:username => "taylorboren@teletech.com", :password => "!QAZ2wsx"}
  @@dev_auth = {:username => "admin", :password => "admin"}

#  def initialize(base_url, auth_hash)
#    @base_url = base_url
#    @auth_hash = auth_hash
#  end

  def self.dev_url
    @@dev_url
  end

  def self.social_auth
    @@social_auth
  end

  def self.wwc_auth
    @@wwc_auth
  end

  def self.dev_auth
    @@dev_auth
  end

  def self.grab(relative_url, auth)
    json = self.get(relative_url, :basic_auth => auth).body
    self.clean(json)
  end

  def self.clean(json)
    return JSON.parse(json.gsub!(/throw [^;]*;/, ''))
  end

  def self.getTags(relative_url, auth)
    json = self.grab(relative_url, auth)
    return json["tags"]
  end

end