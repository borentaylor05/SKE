class TwitterController < ApplicationController
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers
	after_action :allow_iframe

	def get_tweets_from_multiple

		users = ["smh", "taranakinews", "DomPost"]
		tweets = $twitter.get_tweets_from_users(users)
		Rails.logger.info("TWEETS: #{tweets}")
		respond({ tweets: tweets })
	end

end
