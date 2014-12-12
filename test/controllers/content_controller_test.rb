require 'test_helper'

class ContentControllerTest < ActionController::TestCase
  test "new content route" do 
  	params = {
  		api_id: 1, 
		doc_id: 1, 
		title: "TesT",
		jive_id: User.first.jive_id,
		client: Client.first.name,
		featured: false,
		message: "TESTING POST"
  	}
  	post :create, params
  end

  test "setting feature" do
  	params = {
      api_id: 1018,
  		featured: "true"
  	}
  	post :feature, params
  end

  test "attach message" do
  	params = {
  		api_id: 1018,
  		message: "Blah"
  	}
  	post :attach_message, params
  end

  test "update client" do
  	params = {
  		client: Client.last.name,
      api_id: 1018
  	}
  	post :update_client, params
  end

  test "get message" do
  	params = {
  		api_id: 1018
  	}
  	get :get_message, params
  end
end
