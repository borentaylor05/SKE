require 'test_helper'

class CodesControllerTest < ActionController::TestCase
  
	test "new code request" do 
		params = {
			sub_num: 123,
			member_first_name: "test",
			member_last_name: "test",
			member_zip: 11111,
			agent_id: 1234567,
			agent_name: "Agent Test"
		}
		post :new, params
	end

	test "get info" do

		params = {
			token: WwCodeInfo.first.token
		}

		post :get_info, params
	end

	test "get code" do 
		params = {
			agent_id: 1,
			token: WwCodeInfo.first.token 
		}
		post :get_code, params
	end

	test "get proxy" do 
		get :proxy
	end

end
