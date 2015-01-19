require 'test_helper'

class CodesControllerTest < ActionController::TestCase
  
	test "new code request" do 
		params = {
			sub_num: 123,
			member_first: "test",
			member_last: "test",
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

	test "get all codes" do 
		get :get_all
	end

	test "get_people" do 
		get :get_people
	end

	test "load codes" do 
		params = {
			"42.95" => ["one", "two"],
			"39.95" => ["one", "two"],
			"lifetime" => ["one", "two"]
		}
		post :load, params
	end

end
