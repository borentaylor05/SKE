require 'rails_helper'

describe "Messages API", :type => :request do

	before { @me = User.find_by(jive_id: 1) }

	# for /messages?user -> { user: :jive_id }
	it "should have a json response" do 
		get "/messages"
		expect(json).to_not eq(nil)
	end

	it "should fail gracefully if no user found / provided" do 
		get "/messages"
		expect(json["status"]).to eq(1)
	end

	it "should be successful if provided a valid jive user ID" do 
		get "/messages?user=#{User.first.jive_id}"
		expect(json["status"]).to eq(0)
		expect(json["messages"]).to_not eq(nil) 
	end

	# for /message/acknowledge -> { jive_id: :jive_id, message: :message_id }
	it "should have a json response" do 
		get "/messages/acknowledge"
		expect(json).to_not eq(nil)
	end

	it "should fail gracefully if no user found / provided" do 
		get "/messages/acknowledge"
		expect(json["status"]).to eq(1)
	end

end