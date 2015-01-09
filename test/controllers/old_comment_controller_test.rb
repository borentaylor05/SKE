require 'test_helper'

class OldCommentControllerTest < ActionController::TestCase
 
	test "check comments" do
		get :check
	end

	test "toggle comment" do
		param = {
			api: OldComment.first.api_id
		}
		post :toggle
	end
end
