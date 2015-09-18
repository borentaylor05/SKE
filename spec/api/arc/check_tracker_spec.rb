# Purpose: 
# ARC needed a way to track check information, look it up by fields and edit specific info
# They also have the ability to search for checks by the agent that created the entry

# URLs:
# Form: https://social.teletech.com/community/clients/american_red_cross/american-red-cross-information-station/american-red-cross-rdc-team
# Tracker: same URL, below form

# Models (database entities)
# ArcCheckTracker: app/models/arc_check_tracker.rb
# 
# ArcCheckTracker Fields:
# t.string   "check_num"  ---> REQUIRED
# t.decimal  "check_amount", precision: 10, scale: 2  ---> REQUIRED
# t.string   "check_date"  ---> REQUIRED
# t.string   "org"
# t.string   "check_name"  ---> REQUIRED
# t.string   "state"       ---> REQUIRED
# t.string   "tsc_received"  ---> REQUIRED
# t.string   "order_num"
# t.string   "crs"
# t.string   "notes"
# t.string   "sent_back_by"
# t.string   "agent_name"	---> REQUIRED
# t.datetime "created_at",                            null: false
# t.datetime "updated_at",                            null: false
# t.integer  "case_id"   ---> REQUIRED

# Tests routes:
#  match "/arc/api/checks", to: "arc#create_check", via: [:post, :options] 
#  match "/arc/api/checks/:check_id", to: "arc#update_check", via: [:post, :options]
#  match "/arc/api/checks", to: "arc#get_checks", via: :get                            
#  match "/arc/api/checks/agents", to: "arc#get_check_agents", via: :get

require 'rails_helper'

describe "ARC Check Tracker API", :type => :request do

	# for match "/arc/api/checks", to: "arc#create_check", via: [:post, :options] 
	before { 
				@check = FactoryGirl.build(:arc_check_tracker)	
				@check = @check.attributes.symbolize_keys
				@check[:state] = { abbreviation: "AZ" }	
				@check[:check_id] = ArcCheckTracker.first.id		
			}
	
	it "should create a new check tracker" do 		
		before = ArcCheckTracker.count 
		post "/arc/api/checks", @check
		after = ArcCheckTracker.count 
		expect(after).to eq(before+1)
	end

	it "should return status 0 for correct tracker" do 
		post "/arc/api/checks", @check
		expect(json["status"]).to eq(0)
	end

	it "should return status 1 for incorrect tracker" do 
		@check[:check_num] = nil
		post "/arc/api/checks", @check
		expect(json["status"]).to eq(1)
	end

	# for match "/arc/api/checks/:check_id", to: "arc#update_check", via: [:post, :options] 
	# 
	it "should return status 0 on success" do 
		post "/arc/api/checks/#{@check[:check_id]}", @check
		expect(json["status"]).to eq(0)
	end

	it "should return status 0 on success" do 
		post "/arc/api/checks/#{@check[:check_id]}", @check
		expect(json["status"]).to eq(0)
	end

	it "should return 1 with invalid ID" do 
		@check[:check_id] = "ASDASD"
		post "/arc/api/checks/#{@check[:check_id]}", @check
		expect(json["status"]).to eq(1)
	end

	it "should return the updated check on success" do 
		@check[:check_name] = "MYNAME"
		post "/arc/api/checks/#{@check[:check_id]}", @check
		expect(json["check"]["check_name"]).to eq("MYNAME")
	end

	# for match "/arc/api/checks/agents", to: "arc#get_check_agents", via: :get
	# Returns all agents that have created checks. This allows a user to narrow 
	# down results by the agent who made the entries
	
	it "should always return status 0" do 
		get "/arc/api/checks/agents"
		expect(json["status"]).to eq(0)
	end

	it "should have agents key" do 
		get "/arc/api/checks/agents"
		expect(json.has_key?("agents")).to be true
	end

	it "agents should not be null and should be an array" do 
		get "/arc/api/checks/agents"
		expect(json["agents"]).to_not be nil 
		expect(json["agents"].class.to_s).to eq("Array")
	end

	# for match "/arc/api/checks", to: "arc#get_checks", via: :get
	# Returns all checks and their data.  This data is displayed in a table 
	# at url: https://social.teletech.com/community/clients/american_red_cross/american-red-cross-information-station/american-red-cross-rdc-team
	
	it "should return json" do 
		get "/arc/api/checks"
		expect(json).to_not be nil 
	end

	it "should return status 0 on success with no params" do 
		get "/arc/api/checks"
		expect(json["status"]).to eq(0)
	end

	it "should return status 0 on success with search param" do 
		get "/arc/api/checks?search=blah"
		expect(json["status"]).to eq(0)
	end

	it "should return status 0 on success with name param" do 
		get "/arc/api/checks?search=OLD"
		expect(json["status"]).to eq(0)
	end

	it "should return checks key" do 
		get "/arc/api/checks?search=blah"
		expect(json.has_key?("checks")).to be true
	end

	it "checks should not be nil" do 
		get "/arc/api/checks?search=13535"
		expect(json["checks"]).to_not be nil
	end

	it "checks should be an array of checks" do 
		get "/arc/api/checks?search=13535"
		expect(json["checks"].class.to_s).to eq("Array")
	end

	it "checks array should contain ArcCheckTrackers" do
		get "/arc/api/checks?search=13535"
		expect(json["checks"][0].class.to_s).to eq("Hash")
	end

end










