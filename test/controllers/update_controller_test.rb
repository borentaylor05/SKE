require 'test_helper'

class UpdateControllerTest < ActionController::TestCase
  test "create update" do 
  	params = {
  		text: "blah",
  		user_id: User.first.id,
  		client_id: User.first.client_id
  	}
  	post :create
  end
end
