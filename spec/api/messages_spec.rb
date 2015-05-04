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
		post "/message/acknowledge"
		expect(json).to_not eq(nil)
	end

	it "should fail gracefully if no user found / provided" do 
		post "/message/acknowledge"
		expect(json["status"]).to eq(1)
	end

	it "should toggle acknowledged attribute" do 
		mt = MessageTracker.where(acknowledged: false).first
		msg = mt.message
		user = mt.user
		post "/message/acknowledge", { jive_id: user.jive_id, message: msg.id }
		expect(json["status"]).to eq(0)	
		expect(json["acknowledged"]["acknowledged"]).to eq(true)
	end

	# for /message -> { sender: :jive_id, body: text, recipients: [jive_ids] }
	it "should have json response" do 
		post "/message"
		expect(json).to_not eq(nil)
	end

	it "should fail without proper parameters" do 
		post "/message"
		expect(json["status"]).to eq(1)
	end

	it "should respond properly when passed bad body param" do 
		post "/message", { sender: User.first.jive_id, body: "", recipients: [User.last] }
		expect(json["status"]).to eq(1)
		expect(json["error"]).to eq("Body cannot be empty.")
	end

	it "should respond properly when passed bad recipients param" do 
		post "/message", { sender: User.first.jive_id, body: "hggfhgfhgfg", recipients: Array.new }
		expect(json["status"]).to eq(1)
		expect(json["error"]).to eq("There must be at least one recipient.")
	end

	it "should send message to recipients" do 
		post "/message", { sender: User.first.jive_id, body: "hggfhgfhgfg", groups: [{ name: 'Admins', type: 'lob' }] }
		expect(json["status"]).to eq(0)
		c = Client.find_by(name: 'all')
		expect(json["message"]).to eq("Message Sent to #{User.where(client: c).count} people.")
	end	

	# for /messages/all -> { user: :jive_id }
	it "should have json response" do 
		get "/messages/all"
		expect(json).to_not eq(nil)
	end

	it "should respond with error if no user param" do 
		get "/messages/all"
		expect(json["status"]).to eq(1)
	end

	it "should respond with messages if user exists" do 
		get "/messages/all", { user: 1 }
		expect(json["status"]).to eq(0)
		expect(json["messages"].count).to be > 0
	end
end









