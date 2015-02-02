require 'test_helper'

class MessageControllerTest < ActionController::TestCase
  
	test "get unread messaages" do 
		params = {
			user: User.first.jive_id
		}

		get :get_unread_messages, params
	end

	test "acknowledge" do 
		params = {
			user: User.first.jive_id,
			message: User.first.messages.first.id
		}
		post :acknowledge, params
	end

	test "send" do 
		params = {
			sender: User.first.jive_id,
			recipients: [User.last.jive_id],
			body: "BLAH"
		}
		post :send_message, params
	end

end
