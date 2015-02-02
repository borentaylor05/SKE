require 'test_helper'

class DeadlineControllerTest < ActionController::TestCase
  
	test "get deadlines by publication" do 
		params = {
			pub: "Southland Times"
		}
		get :get_deadlines_by_pub, params
	end

	test "get all pubs" do 
		get :get_pubs
	end

end
