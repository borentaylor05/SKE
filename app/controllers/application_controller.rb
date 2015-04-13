class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  require 'Jive' # needed for production despite being autoloaded

  $admin_user = User.find_by(jive_id: 99999999)
  $instance = "http://localhost:8080"
  $current_url = "http://localhost:8080/api/core/v3"
  $current_auth = Jive.auth
  $whitelist = [
      'http://localhost:8080', 
      'http://localhost:8090', 
      'https://social.teletech.com', 
      'https://lit-inlet-2632.herokuapp.com',
      'https://jivedemo-teletech-gtm-alliances.jiveon.com'
    ]
  $wl_domains = [
      'localhost:8080', 
      'localhost:8090', 
      'social.teletech.com', 
      'jivedemo-teletech-gtm-alliances.jiveon.com'
  ]
  $wl_ips = [
      '170.65.128.6',
      '204.93.64.4', # demo site
      '::1',
      '127.0.0.1',
      '10.170.67.38', # activity engine SKE,
      '10.170.67.44', # node
      '10.170.67.43', # node
      '10.170.67.42', # node
      '10.170.67.45'  # node
  ]

  $cloud_ip = IPAddr.new ENV['CLOUD_IP']

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = check_origin
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  def check_origin
    if admin_signed_in?
      return request.headers['origin']
    elsif $cloud_ip.include?(request.remote_ip)
        return request.headers['origin']
    elsif origin_allowed?
      return request.headers['origin']
    else
      raise "Unauthorized - Invalid Origin - IP: #{request.remote_ip} - Domain - #{request.headers['origin']} - Referrer - #{request.referrer}"
    end
  end

  def origin_allowed?
    if $whitelist.include?(request.headers['origin']) or (request.referrer and $wl_domains.include?(URI(request.referrer).host)) or $wl_ips.include?(request.remote_ip) or request.referrer == 'https://lit-inlet-2632.herokuapp.com/web/IE9/proxy.html'
      Rails.logger.info("Authorized! --> HREF: #{request.referrer}, IP: #{request.remote_ip}, Domain: #{request.headers['origin']}") 
      return true
    else
      return false
    end
  end

  def get_user(jive_user_id, client = nil)
    jive_user_id = jive_user_id.to_s
    u = User.find_by(jive_id: jive_user_id)
    if u.nil?
      ju = Jive.grab("#{$current_url}/people/#{jive_user_id}", $current_auth)
      user = User.new(
        employee_id: ju["jive"]["username"],
        jive_id: ju["id"],
        client: client
      )
      if user.valid?
        user.save
        return user
      else
        return { error: "user.errors.full_messages" }
      end
      return ju
    else
      return u
    end
  end

  def to_boolean(str)
  	str == 'true'
  end

  def respond(response)
  	respond_to do |format|
  		format.any(:json, :html) { render json: response }
  	end
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

  def generate_token(length)
    token = Digest::SHA1.hexdigest([Time.now, rand].join)[0...length]
    while WwCodeInfo.exists?(token: token)
      token = Digest::SHA1.hexdigest([Time.now, rand].join)[0...length]
    end
    return token
  end

  def generate_access_token
      token = Digest::SHA1.hexdigest([Time.now, rand].join)[0...30] 
      while WwCodeInfo.exists?(token: token)
        token = Digest::SHA1.hexdigest([Time.now, rand].join)[0...30]
      end
      Token.create!(token: token)
      return token 
  end

  def token_valid(token)
    if Token.exists?(token: token) 
      five_minutes_ago = Time.now - 5.minutes
      created = Token.find_by(token: token).created_at
      # was token generated in last 5 minutes?
      if created >= five_minutes_ago and created <= Time.now
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def handle_expired_session
    respond({ status: 1, type: "oauth", error: "Session expired, reauthenticating." })
  end

  def user_quick_create(user)
    u = User.new(jive_id: user[:jive_id], employee_id: user[:employee_id], name: user[:name])
    u.valid ? u.save : logger.info("#{u.errors.full_messages}")
  end

  def numeric?(string)
      true if Float(string) rescue false
  end

end




