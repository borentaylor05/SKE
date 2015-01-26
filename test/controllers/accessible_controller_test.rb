require 'test_helper'

class AccessibleControllerTest < ActionController::TestCase
  
	test "get acc verification" do 
		get :cdc_verification
	end

	test "get address book upload" do 
		get :upload_address_book
	end

	test "get a to z upload" do 
		get :upload_a_to_z
	end

	test "view a to z" do 
		get :edit_a_to_z
	end

	test "get all topics" do 
		get :get_all_topics
	end

	test "get topic" do 
		get :get_topic
	end

	test "save changes" do 
		params = {
			aka: "ASDASD",
			owner: "ASDSAD",
			scope: "IN",
			notes: "AASDSAD",
			pr: false,
			cdc_link: "ADASDSAD",
			spanish: true
		}
		post :az_save_changes, params
	end

	test "search" do 
		get :cdc_search
	end

end
