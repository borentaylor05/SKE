class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  require 'Jive' # needed for production despite being autoloaded

  $current_url = "http://localhost:8080/api/core/v3"
  $current_auth = Jive.auth

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = check_origin
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  def check_origin
  Rails.logger.info(request.headers['origin']) 
    whitelist = [
      'http://localhost:8080', 
      'http://localhost:3000', 
      'https://social.teletech.com', 
      "https://lit-inlet-2632.herokuapp.com",
      "170.65.128.6"
    ]
    if whitelist.include?(request.headers['origin'])
      return request.headers['origin']
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

end




