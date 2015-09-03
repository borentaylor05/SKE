require 'rails_helper'

describe "Comments API", :type => :request do

	before { @content = FactoryGirl.create(:old_content) }
	before { @comment = FactoryGirl.create(:old_comment) }

	# for /user/update-client, { :data[:api, :comments(number of comments), :commentsUrl, :doc(HTML link to doc)] }
	# it "respond properly to existing content" do
	# 	hash = @content.attributes
	# 	hash[:api] = @content.api_id # because I named the json attr api, not api_id as in the model
	# 	post "/old/content", { data: [hash] }
	# 	expect(response).to be_success
	# 	expect(json['status']).to eq(0)
	# 	expect(json['newComments']).not_to eq(nil)
	# 	expect(json['created']).not_to eq(nil)
	# end	

	# it "respond properly to new content" do
	# 	hash = { api: 123213, comments: 0, title: "TEST", link: "blah", commentsUrl: "blah" }
	# 	post "/old/content", { data: [hash] }
	# 	expect(response).to be_success
	# 	expect(json['status']).to eq(0)
	# 	expect(json['newComments']).not_to eq(nil)
	# 	expect(json['created'].count).to eq(1)
	# end	

	# it "should respond with error if no data attribute" do
	# 	post "/old/content", { }
	# 	expect(response).to be_success
	# 	expect(json['status']).to eq(1)
	# 	expect(json['error']).to eq("Request needs data property with content attributes. Data must be an array.")
	# end

	# it "should respond with error if :data is not array" do
	# 	post "/old/content", { data: "ASDASD" }
	# 	expect(response).to be_success
	# 	expect(json['status']).to eq(1)
	# 	expect(json['error']).to eq("Request needs data property with content attributes. Data must be an array.")
	# end

	# # for /old/comments, { data: [:content(api ID of parent), :api(api ID of comment), :index(array index from front-end - not used anymore)] } 
	# # Route Purpose: returns new and existing comments in an array along with their current resolved status
	# it "(comment) should respond properly to existing comment" do
	# 	hash = @comment.attributes
	# 	hash[:api] = @comment.api_id
	# 	hash[:content] = @content.api_id
	# 	post "/old/comments", { data: [hash] }
	# 	expect(response).to be_success
	# 	expect(json.class).to eq(Array)
	# 	expect(json.count).to be > 0
	# end

	# it "(comment) should respond properly to new comment" do
	# 	hash = { api: 123232, content: @content.api_id }
	# 	post "/old/comments", { data: [hash] }
	# 	expect(response).to be_success
	# 	expect(json[0]["resolved"]).to eq(false)
	# 	expect(json.class).to eq(Array)
	# 	expect(json.count).to be > 0
	# end

	# it "should fail with nil api_id" do 
	# 	hash = { api: nil, content: @content.api_id }
	# 	post "/old/comments", { data: [hash] }
	# 	expect(response).to be_success
	# 	expect(json.class).to eq(Hash)
	# 	expect(json["error"]).to eq("Error - Bad Request - API ID cannot be nil")
	# end

	# it "should fail with nil content" do 
	# 	hash = { api: 123232, content: nil }
	# 	post "/old/comments", { data: [hash] }
	# 	expect(response).to be_success
	# 	expect(json.class).to eq(Hash)
	# 	expect(json["error"]).to eq("Error - Bad Request - Content API ID cannot be nil")
	# end

	# it "should respond with error if no data attribute" do
	# 	post "/old/comments", { }
	# 	expect(response).to be_success
	# 	expect(json['status']).to eq(1)
	# 	expect(json['error']).to eq("Request needs data property with content attributes. Data must be an array.")
	# end

	# it "should respond with error if :data is not array" do
	# 	post "/old/comments", { data: "ASDASD" }
	# 	expect(response).to be_success
	# 	expect(json['status']).to eq(1)
	# 	expect(json['error']).to eq("Request needs data property with content attributes. Data must be an array.")
	# end

	# # for /old/comment/toggle, { :api(api ID of comment) }
	# # Purpose: toggles resolved status of comment
	# it "should fail gracefully if no api param" do 
	# 	post "/old/comment/toggle", { blah: @comment.api_id }
	# 	expect(json['status']).to eq(1)
	# 	expect(json['error']).to eq("Comment #{nil} does not exist")
	# end

	# it "should fail gracefully if no comment is found" do 
	# 	post "/old/comment/toggle", { api: "notarealid" }
	# 	expect(json['status']).to eq(1)
	# 	expect(json['error']).to eq("Comment notarealid does not exist")
	# end

	# it "should toggle comment status" do 
	# 	prev = @comment.resolved
	# 	post "/old/comment/toggle", { api: @comment.api_id }
	# 	expect(json['status']).to eq(0)
	# 	expect(json['com']['resolved']).not_to eq(prev)
	# 	expect(json['com']['resolved']).to eq(true) or eq(false)
	# end

end






