require 'test_helper'

class PostControllerTest < ActionController::TestCase
  
	test "get posts" do
		get :all
	end

end
