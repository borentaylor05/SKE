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
      api_id: Content.first.api_id,
  		featured: "true"
  	}
  	post :feature, params
  end

  test "attach message" do
  	params = {
  		api_id: Content.first.api_id,
  		message: "Blah"
  	}
  	post :attach_message, params
  end

  test "update client" do
  	params = {
  		client: Client.last.name,
      api_id: Content.first.api_id
  	}
  	post :update_client, params
  end

  test "get message" do
  	params = {
  		api_id: Content.first.api_id
  	}
  	get :get_message, params
  end

  test "post webhooks content" do
    params = {
      api_id: 1,
      doc_id: 1001,
      title: "Test",
      jive_user_id: User.first.id,
      client_kb_id: 1005,
      message: "Test Message",
      cType: "document"
    }
    post :webhooks_content, params
  end

  test "get all" do
    get :all
  end

end
