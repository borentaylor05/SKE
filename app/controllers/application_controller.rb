class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  $current_url = "http://localhost:8080/api/core/v3"
  $current_auth = Jive.dev_auth

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




