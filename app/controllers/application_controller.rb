class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  require 'Jive' # needed for production despite being autoloaded

  $token = ""
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

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end



  def access_check
    # if 1) Admin not signed in 2) origin not in whitelist 3) IP is not localhost 4) not being sent by IE 9 proxy page
    if !admin_signed_in? and !$whitelist.include?(request.headers['origin']) and request.remote_ip != '127.0.0.1' 
      return redirect_to "/admins/sign_in"
    end
  end  

  def check_origin
    Rails.logger.info("Remote (Requesting) IP #{request.remote_ip}") 
    Rails.logger.info("Remote (Requesting) DOMAIN #{request.headers['origin']}") 
    Rails.logger.info("Referrer (Requesting) URL --> #{request.referrer}") 
    if admin_signed_in?
      return request.headers['origin']
    elsif origin_allowed?
      return request.headers['origin']
    else
      raise "Unauthorized - Invalid Origin"
    end
  end

  def origin_allowed?
    if $whitelist.include?(request.headers['origin']) or (request.referrer and $wl_domains.include?(URI(request.referrer).host)) or request.remote_ip == "::1" or request.remote_ip == '127.0.0.1' or request.referrer == 'https://lit-inlet-2632.herokuapp.com/web/IE9/proxy.html'
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

  def verify
    logger.info("Origin -----> #{request.headers['origin']}")
    if (request.headers['origin'].nil? or !$whitelist.include?(request.headers['origin'])) and !token_valid(params[:token])
      Rails.logger.info("URL SHOULD BE ----> #{request.original_url.gsub!(/token(=[^&]*)?|^token(=[^&]*)/, '')}")
      cookies[:url] = request.original_url
      cookies[:action] = params[:action]
      if !params.has_key?("token")
        flash[:error] = "Access to this page requires a password." 
        redirect_to "/authenticate"
      else
        if !token_valid(params[:token])
          flash[:error] = "The token provided was invalid.  Tokens expire after 5 minutes."
          redirect_to "/authenticate"
        end
      end
    else
      Rails.logger.info("WRRRRRROOOOOOOOONG")
      return true
    end
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

  def copy_session
    Rails.logger.info("Session ----> #{session['token']}")
    @session_copy = session
  end

  def user_quick_create(user)
    u = User.new(jive_id: user[:jive_id], employee_id: user[:employee_id], name: user[:name])
    u.valid ? u.save : logger.info("#{u.errors.full_messages}")
  end

end




