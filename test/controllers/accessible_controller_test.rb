require 'test_helper'

class AccessibleControllerTest < ActionController::TestCase
  
	test "get address book upload" do 
		get :upload_address_book
	end

	test "get fx classifications upload" do 
		get :upload_fx_classifications
		assert_response 302
	end

	test "get a to z upload" do 
		get :upload_a_to_z
	end

	test "get deadline upload" do 
		get :upload_deadlines
	end

	test "view a to z" do 
		get :edit_a_to_z
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

	test "get authenticate" do 
		get :authenticate
	end

	test "verify user" do 
		post :verify_user, {password: "blah"}
	end

	test "edit deadlines" do 
		get :fx_edit_deadlines
	end

	test "save deadline" do 
		params = {
			id: Deadline.first.id,
			publication: "ADSD",
			nz_time: "ASDSAD",
			mla_time: "ASDASDS",
			run_day: "ASDSAD"
		}
		put :fx_save_deadline, params
	end

end
