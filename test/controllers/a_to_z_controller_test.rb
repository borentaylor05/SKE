require 'test_helper'

class AToZControllerTest < ActionController::TestCase
  
	test "search" do 
		params = {
			search: "HIV"
		}
		get :cdc_search, params
	end

	test "get range" do 
		get :get_range
	end

	test "get topic" do 
		get :get_topic
	end

end
