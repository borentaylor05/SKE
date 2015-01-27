require 'test_helper'

class AddressBookControllerTest < ActionController::TestCase
  
	test "get all" do 
		get :get_all
	end

	test "get entry" do 
		get :get_entry
	end

end
