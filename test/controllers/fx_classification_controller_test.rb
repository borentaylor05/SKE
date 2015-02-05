require 'test_helper'

class FxClassificationControllerTest < ActionController::TestCase
  
	test "get categories" do 
		get :get_categories
		assert_response :success
	end

end
