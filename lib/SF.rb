require "sinatra"
require "omniauth"
require "omniauth-salesforce"

class MyApplication < Sinatra::Base
	use Rack::Session
	use OmniAuth::Builder do
		provider :salesforce, ENV['SF_CLIENT_ID'], ENV['SF_CLIENT_SECRET']
	end

	configure do
		enable :logging
		enable :sessions
		set :show_exceptions, false
		set :session_secret, ENV['SECRET']
	end

	before /^(?!\/(auth.*))/ do   
	    redirect '/authenticate' unless session[:instance_url]
	end

	helpers do
		def client
		@client ||= Force.new instance_url:  session['instance_url'], 
							oauth_token:   session['token'],
							refresh_token: session['refresh_token'],
							client_id:     ENV['SALESFORCE_KEY'],
							client_secret: ENV['SALESFORCE_SECRET']
		end
	end

	get '/' do
    logger.info "Visited home page"
    @accounts= client.query("select Id, Name from Account")    
    erb :index
  end


  get '/authenticate' do
    redirect "/auth/salesforce"
  end


  get '/auth/salesforce/callback' do
    logger.info "#{env["omniauth.auth"]["extra"]["display_name"]} just authenticated"
    credentials = env["omniauth.auth"]["credentials"]
    session['token'] = credentials["token"]
    session['refresh_token'] = credentials["refresh_token"]
    session['instance_url'] = credentials["instance_url"]
    redirect '/'
  end

  get '/auth/failure' do
    params[:message]
  end

  get '/unauthenticate' do
    session.clear 
    'Goodbye - you are now logged out'
  end

  error Force::UnauthorizedError do
    redirect "/auth/salesforce"
  end

  error do
    "There was an error.  Perhaps you need to re-authenticate to /authenticate ?  Here are the details: " + env['sinatra.error'].name
  end

  run! if app_file == $0

end