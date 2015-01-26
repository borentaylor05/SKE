# Test from Rails Console:
# load "#{Rails.root}/config/initializers/twitter.rb"

$twitter = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
end

def $twitter.get_last_tweet(user)
    options = {count: 1, include_rts: true}
    user_timeline(user, options)
end

def $twitter.get_tweets_from_users(users)
	all = [];
	users.each do |u|
		all.push($twitter.get_last_tweet(u).first)
	end
	return all
end