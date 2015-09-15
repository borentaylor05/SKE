
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
		post "/arc/api/checks/:check_id", @check
		puts @check[:check_id]
		expect(json["status"]).to eq(0)
	end

	it "should return status 0 on success" do 
		post "/arc/api/checks/:check_id", @check
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

end










