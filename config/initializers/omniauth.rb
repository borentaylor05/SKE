OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
	provider :salesforce, ENV['SF_CLIENT_ID'], ENV['SF_CLIENT_SECRET']
end