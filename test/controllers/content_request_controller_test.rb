require 'test_helper'

class ContentRequestControllerTest < ActionController::TestCase
  	test "submit new content request" do
  		req = {
  			docTitle: "Blah",
  			summary: "Blah",
  			type: "new"
  		}
  		post :new_content, req
  	end

  	test "submit revision request" do
  		req = {
  			docNum: Content.first.doc_id,
  			summary: "Blah",
  			type: "new"
  		}
  		post :revision, req
  	end

  	test "get all requests" do 
  		get :all
  	end
end
