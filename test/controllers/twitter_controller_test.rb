require 'test_helper'

class TwitterControllerTest < ActionController::TestCase
  
	test "get tweets from multiple user" do 
		get :get_tweets_from_multiple
	end

end
