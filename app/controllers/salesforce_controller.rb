class SalesforceController < ApplicationController
	skip_before_filter :verify_authenticity_token
	after_filter :cors_set_access_control_headers
	after_action :allow_iframe
	rescue_from Restforce::UnauthorizedError, with: :handle_expired_session

	def search_for_contact
		begin
			client = create_client(params[:user])
			searchTerm = params[:search]
			if client
				respond({ status: 0, results: client.query("select contact.Account.Name, contact.Account.Website, contact.name, contact.phone from contact WHERE contact.name LIKE '%#{searchTerm}%'") })
				cleanup_oauth_creds(params[:user]) # last so response is quicker
			else
				respond({ status: 1, error: "Unable to create client." })
			end
		rescue Restforce::UnauthorizedError
			respond({ status: 1, type: "oauth", error: "Session expired, reauthenticating." })
		end
	end

	def authenticate
		session['user'] = params[:user]
		logger.info("USER -----------------> #{session['user']}")
		redirect_to "/auth/salesforce"
	end

	def callback
		logger.info "#{env["omniauth.auth"]["extra"]["display_name"]} just authenticated"
		credentials = env["omniauth.auth"]["credentials"]
		sf = SfOAuth.new(
			token: credentials["token"],
			refresh_token: credentials["refresh_token"],
			instance_url: credentials["instance_url"],
			user: User.find_by(jive_id: session['user'])
		)
		sf.save
	#	session['token'] = credentials["token"]
	#	session['refresh_token'] = credentials["refresh_token"]
	#	session['instance_url'] = credentials["instance_url"]
		
	end

	def failure
		params[:message]
	end

	def unauthenticate
		session.clear 
		'Goodbye - you are now logged out'
	end


	private 

		def create_client(user)
			if User.find_by(jive_id: user).sf_o_auths.any?
				sf_auth = User.find_by(jive_id: user).sf_o_auths.first
				if sf_auth.nil?
					respond({ status: 1, type: "oauth", error: "No OAuth Entry." })
					return false
				else
					client = Restforce.new :oauth_token => sf_auth.token,
						:refresh_token => sf_auth.refresh_token,
						:instance_url  => sf_auth.instance_url,
						:client_id     => ENV['SF_CLIENT_ID'],
						:client_secret => ENV['SF_CLIENT_SECRET']
					return client
				end	
			else
				respond({ status: 1, type: "oauth", error: "No OAuth Entry." })
			end	
		end

		def cleanup_oauth_creds(user)
			# only store latest oauth creds in db
			if(User.find_by(jive_id: user).sf_o_auths.count > 1)
				User.find_by(jive_id: user).sf_o_auths.last.destroy
			end
		end

end
