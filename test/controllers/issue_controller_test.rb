require 'test_helper'

class IssueControllerTest < ActionController::TestCase
  
	test "create issue" do 
		params = {
			api_id: 1000,
			created_by: User.first.jive_id,
			doc: Content.first.api_id,
			issue_type: "comment",
			url: "http://test.com",
			message: "Blah"
		}
		post :webhook_create_issue, params
	end

	test "resolve issue" do
		params = {
			id: Issue.first.id 
		}
		post :resolve, params
	end
	test "unresolve issue" do
		params = {
			id: Issue.first.id 
		}
		post :unresolve, params
	end
end
