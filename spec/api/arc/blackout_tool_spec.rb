# Purpose: 
# Nicole was spending many hours a day updating a massive SKE document that contained
# all cities and states as well as those city's blackout and yellow out dates.
# To save her time, I built this tool, and it is very complex.
# It comes in 2 parts:
# 	1) The form to add blackout dates
# 		- This form allows you to select a state, input comma-separated cities for the
# 			selected state (e.g. Dallas, Houston) and then to input blackout or
# 			yellow out dates and associated notes.  This form also has a group function
# 			that allows you to create groups by state and use them in the future.
# 			It also has a 'Check Cities' function that is meant to prevent typos in 
# 			city names.
# 	2) The agent-facing page that allows agents to look up dates by city
# 		- This part allows filtering by city names and clicking that city's button
# 			shows all dates for that city. Certain users (now just Nicole and myself)
# 			have the options to: 
# 				1) Delete one specific date 
# 				2) Delete that date for all cities
# 				3) Switch the date from black to yellow.	
# 				4) Delete a city
# 	

# URLs:
# Agent Facing (below ARC Links): https://social.teletech.com/community/clients/american_red_cross/american-red-cross-information-station/american-red-cross--bgst-knowledgebase
# CS (Nicole) Facing: https://social.teletech.com/community/clients/american_red_cross/american-red-cross-information-station/american-red-cross--bgst-knowledgebase/american-red-cross-community-specialist-reporting-space

# Models (database entities)
# ArcBlackoutDate: app/models/arc_blackout_date.rb
# ArcCityState: app/models/arc_city_state.rb
# ArcBlackoutTracker: app/models/arc_blackout_tracker.rb
# ArcCityStateGroup: app/models/arc_city_state_group.rb
# ArcGroupTracker: app/models/arc_group_tracker.rb
# 
# Relationships:
# 
# NOTE: Think of ArcBlackoutTracker as a table that tracks which cities have which dates
# 
# ArcBlackoutTracker belongs_to ArcBlackoutDate
# ArcBlackoutTracker belongs_to ArcCityState
# ArcCityState has_many ArcBlackoutTrackers
# ArcCityState has_many ArcBlackoutDates through ArcBlackoutTrackers (see description below)
# ArcCityState belongs_to State
# ArcBlackoutDate has_many ArcBlackoutTrackers
# ArcBlackoutDate has_many ArcCityStates through ArcBlackoutTrackers (see description below)
# ArcGroupTracker belongs_to ArcCityState
# ArcGroupTracker belongs_to ArcCityStateGroup
# ArcCityState has_many ArcGroupTrackers
# ArcCityState has_many ArcCityStateGroups through ArcGroupTrackers
# ArcCityStateGroup has_many ArcGroupTrackers
# ArcCityStateGroup has_many ArcCityStateGroups through ArcGroupTrackers
#
# 
# Has Many through: how it works: Go to http://guides.rubyonrails.org/association_basics.html#the-has-many-through-association
# It allows you to have many to many relationships and access those relationships like:
# ArcCityStates.first.arc_blackout_dates - that gives you all dates for the first city in the DB 
# 
# ArcBlackoutTracker Fields:
# t.integer  "arc_blackout_date_id" --> REQUIRED
# t.integer  "arc_city_state_id"   --> REQUIRED
# t.datetime "created_at",           null: false
# t.datetime "updated_at",           null: false
# 
# ArcCityState Fields:
# t.string   "name" --> REQUIRED
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false
# t.integer  "state_id"  --> REQUIRED
# 
# ArcBlackoutDate Fields: 
# t.string   "date"
# t.string   "notes"
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false
# t.date     "expires"
# t.string   "date_type"
# 
# NOTES on ArcBlackoutDate: 
# 	- if date then date must be of format 09/03/2015 (9/3/2015 works too)
# 	- each date must have a type of 'black' or 'yellow'
# 	- Date or notes must be present
# 	- expires is set based on the date format above
# 	- there is a scheduled task that runs every night to delete past dates
# 		- located in app/lib/tasks/arc.rake#remove_old_blackout_dates
# 		
# ArcCityStateGroup Fields:
# t.string   "name"  --> REQUIRED
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false
# t.integer  "state_id" --> REQUIRED
# 
# ArcGroupTracker Fields: 
# t.integer  "arc_city_state_id"   --> REQUIRED
# t.integer  "arc_city_state_group_id" --> REQUIRED
# t.datetime "created_at",              null: false
# t.datetime "updated_at",              null: false

# Tests routes:
# match "/arc/api/blackout-dates", to: "arc#create_blackout_dates", via: [:post, :options]
# match "/arc/api/blackout-dates/check", to: "arc#check_cities", via: [:post, :options]
# match "/arc/api/blackout-dates/:id/switch",  to: "arc#bo_switch", via: [:post, :options]
# match "/arc/api/blackout-dates/:id", to: "arc#delete_bo_date", via: [:delete, :options]
# match "/arc/api/cities/:id", to: "arc#delete_city", via: [:delete, :options]
# match "/arc/api/blackout-dates/:city/:state", to: "arc#get_blackout_dates", via: :get
# match "/arc/api/blackout-dates/group", to: "arc#get_groups", via: :get
# match "/arc/api/blackout-dates/group", to: "arc#new_group", via: [:post, :options]
# match "/arc/api/cities", to: "arc#get_all_cities", via: :get

require 'rails_helper'

describe "ARC API", :type => :request do

	before { @create_params = { date: "01/01/2015", date_notes: "Notes", 
										yellow: "01/02/2016", yellow_notes: "YNotes", 
										state: {name: "New York", abbreviation: "ny"}, 
										cities: "Suffolk, Nassau, Hornell"
										} 
									}
	before { @group_params = { cities: "Suffolk, Nassau, Hornell, New York", state: "NY", name: "TEST" } }

	# for /arc/api/cities
	it "/arc/api/cities should return json" do 
		get "/arc/api/cities"
		expect(json).to_not be nil
	end

	it "/arc/api/cities should return cities" do 
		get "/arc/api/cities"
		expect(json["cities"]).to_not be nil
	end

	it "should return all cities" do 
		get "/arc/api/cities"
		c = ArcCityState.count
		expect(json["cities"].count).to be c
	end

	it "should have city and state for every object" do 
		get "/arc/api/cities"
		json["cities"].each do |c|
			expect(c["state"]).to_not be nil
			expect(c["city"]).to_not be nil
		end
	end

	#for /arc/api/blackout-dates/check -> params { cities: [], state: abbreviation }
	it "should return json (/arc/api/blackout-dates/check)" do 
		post "/arc/api/blackout-dates/check", { cities: ['blah', 'blaSD2'], state: "NY"}
		expect(json).to_not be nil
	end

	it "should return an array of cities (/arc/api/blackout-dates/check)" do 
		post "/arc/api/blackout-dates/check", { cities: ['blah', 'blaSD2'], state: "NY"}
		expect(json["cities"].class.name).to_not be "Array"
	end

	it "should return json (/arc/api/blackout-dates/check)" do 
		post "/arc/api/blackout-dates/check", { cities: ['blah', 'blaSD2'], state: "NY"}
		expect(json["cities"].class.name).to_not be "Array"
	end

	it "should return city name and false for fake city (/arc/api/blackout-dates/check)" do 
		post "/arc/api/blackout-dates/check", { cities: ['blah', 'blaSD2'], state: "NY"}
		expect(json["cities"][0]["name"]).to eq('blah')
		expect(json["cities"][0]["exists"]).to be false
	end

	it "should return city name and false for fake city (/arc/api/blackout-dates/check)" do 
		post "/arc/api/blackout-dates/check", { cities: ['sacramento', 'blaSD2'], state: "CA"}
		expect(json["cities"][0]["name"]).to eq('sacramento')
		expect(json["cities"][0]["exists"]).to be true
		expect(json["cities"][1]["exists"]).to be false
	end	

	# for "/arc/api/blackout-dates", to: "arc#create_blackout_dates"
	# params -> { date: string, date_notes: string, yellow: string, yellow_notes: string }
	
	it "should pass if yellow date is nil but notes are not" do 
		@create_params[:date] = nil 
		@create_params[:date_notes] = nil 
		@create_params[:yellow] = nil 
		post "/arc/api/blackout-dates", @create_params
		expect(json["status"]).to eq(0)
	end

	it "should pass if bo date is nil but notes are not" do 
		@create_params[:date] = nil 
		@create_params[:yellow_notes] = nil 
		@create_params[:yellow] = nil 
		post "/arc/api/blackout-dates", @create_params
		expect(json["status"]).to eq(0)
	end

	it "should return json (/arc/api/blackout-dates)" do 
		post "/arc/api/blackout-dates", @create_params
		expect(json).to_not be nil
	end

	it "should have zero errors for valid cities and dates" do
		post "/arc/api/blackout-dates", @create_params
		expect(json["errors"].count).to eq(0)
	end

	it "should not pass with an invalid blackout date" do 
		invalid_dates = ['asdadasd', '131232132', '1222/2222/2222', '2222/1/2015', '4/444/2015', '12/31/32']
		invalid_dates.each do |date|
			@create_params[:date] = date
			post "/arc/api/blackout-dates", @create_params 
			expect(json["status"]).to eq(1)
		end
	end

	it "should not pass with an invalid yellow date" do 
		invalid_dates = ['asdadasd', '131232132', '1222/2222/2222', '2222/1/2015', '4/444/2015', '12/31/32']
		invalid_dates.each do |date|
			@create_params[:yellow] = date
			post "/arc/api/blackout-dates", @create_params 
			expect(json["status"]).to eq(1)
		end
	end	

	it "should not pass if date and yellow are nil (and all notes are nil)" do 
		@create_params[:date] = nil 
		@create_params[:yellow] = nil 
		@create_params[:yellow_notes] = nil 
		@create_params[:date_notes] = nil
		post "/arc/api/blackout-dates", @create_params
		expect(json["status"]).to eq(1) 
	end

	it "should send proper success message" do 
		post "/arc/api/blackout-dates", @create_params
		expect(json["message"]).to eq("3 of 3 saved successfully.")
	end

	# Tests for group functionality
	# params -> { cities: string,string,string,etc. , state: abbreviation, name: string }
	it "should respond with json after POST (/arc/api/blackout-dates/group)" do 
		post "/arc/api/blackout-dates/group", @group_params
		expect(json).to_not be nil
	end

	it "POST /arc/api/blackout-dates/group - should be one more group after request" do 
		before = ArcCityStateGroup.count 
		post "/arc/api/blackout-dates/group", @group_params
		after = ArcCityStateGroup.count 
		expect(after).to eq(before+1)
	end

	it "POST /arc/api/blackout-dates/group - should be x more trackers after request" do 
		before = ArcGroupTracker.count 
		cities = @group_params[:cities].split(",").count
		post "/arc/api/blackout-dates/group", @group_params
		after = ArcGroupTracker.count 
		expect(after).to eq(before+cities)
	end

	it "POST /arc/api/blackout-dates/group - should respond with a group" do 
		post "/arc/api/blackout-dates/group", @group_params
		expect(json["group"]).to_not be nil 
	end

	it "POST /arc/api/blackout-dates/group - pass with blank yellow date" do 
		@create_params[:date_notes] = nil 
		@create_params[:yellow_notes] = nil 
		@create_params[:date] = ""
		@create_params[:yellow] = "09/23/2015"
		post "/arc/api/blackout-dates", @create_params
		expect(json["status"]).to eq(0)
	end

	it "POST /arc/api/blackout-dates/group - pass with blank backout date" do 
		@create_params[:date_notes] = nil 
		@create_params[:yellow_notes] = nil 
		@create_params[:date] = "09/23/2015"
		@create_params[:yellow] = ""
		post "/arc/api/blackout-dates", @create_params
		expect(json["status"]).to eq(0)
	end

	it "POST /arc/api/blackout-dates/group - pass with blank yellow date and date range" do 
		@create_params[:date_notes] = nil 
		@create_params[:yellow_notes] = nil 
		@create_params[:date] = "09/23/2015-09/30/2015"
		@create_params[:yellow] = ""
		post "/arc/api/blackout-dates", @create_params
		expect(json["status"]).to eq(0)
	end

	it "POST /arc/api/blackout-dates/group - pass with blank black date and yellow range" do 
		@create_params[:date_notes] = nil 
		@create_params[:yellow_notes] = nil 
		@create_params[:date] = ""
		@create_params[:yellow] = "09/23/2015-09/30/2015"
		post "/arc/api/blackout-dates", @create_params
		expect(json["status"]).to eq(0)
	end

	it "POST /arc/api/blackout-dates/group - should not pass if all are nil or blank" do 
		@create_params[:date_notes] = nil 
		@create_params[:yellow_notes] = nil 
		@create_params[:date] = ""
		@create_params[:yellow] = ""
		post "/arc/api/blackout-dates", @create_params
		expect(json["status"]).to eq(1)
	end

	it "POST /arc/api/blackout-dates/group - should respond with a group" do 
		post "/arc/api/blackout-dates/group", @group_params
		expect(json["group"]["name"]).to_not be nil 
	end

	it "should respond with error when no state" do 
		@group_params[:state] = nil 
		post "/arc/api/blackout-dates/group", @group_params
		expect(json["status"]).to eq(1)
	end

	it "should respond with error when no cities" do 
		@group_params[:cities] = nil 
		post "/arc/api/blackout-dates/group", @group_params
		expect(json["status"]).to eq(1)
	end

	it "should respond with error when no name" do 
		@group_params[:name] = nil 
		post "/arc/api/blackout-dates/group", @group_params
		expect(json["status"]).to eq(1)
	end

	it "should respond with json after GET (/arc/api/blackout-dates/group)" do 
		get "/arc/api/blackout-dates/group", { state: "NY" }
		expect(json).to_not be nil
	end

	it "GET should respond with a 'groups' object (/arc/api/blackout-dates/group)" do 
		get "/arc/api/blackout-dates/group", { state: "NY" }
		expect(json["groups"]).to_not be nil
	end

	it "GET /arc/api/blackout-dates/group - each group should have a name and cities property " do 
		post "/arc/api/blackout-dates/group", @group_params
		get "/arc/api/blackout-dates/group", { state: "NY" }
		expect(json["groups"][0]["name"]).to_not be nil
		expect(json["groups"][0]["cities"]).to_not be nil
	end

	it "DELETE /arc/api/blackout-dates/:id - should respond with json" do 
		id = ArcBlackoutDate.first.id
		delete "/arc/api/blackout-dates/#{id}"
		expect(json).to_not be nil
	end

	it "DELETE /arc/api/blackout-dates/:id - respond with status 0 if BO date found" do 
		bo = ArcBlackoutDate.first
		city = bo.arc_city_states.first
		delete "/arc/api/blackout-dates/#{bo.id}?city_id=#{city.id}"
		expect(json["status"]).to eq(0)
	end

	it "DELETE /arc/api/blackout-dates/:id?all=true - should delete BO Date and associated trackers" do 
		id = ArcBlackoutDate.first.id
		bo = ArcBlackoutDate.find_by(id: id)
		before = ArcBlackoutDate.count
		all = ArcBlackoutTracker.count
		before2 = bo.arc_blackout_trackers.count 
		delete "/arc/api/blackout-dates/#{id}?all=true"
		after = ArcBlackoutDate.count
		expect(after).to eq(before-1)
		expect(ArcBlackoutTracker.count).to eq(all-before2)
	end

	it "DELETE /arc/api/blackout-dates/:id?all=false - should delete BO Date and associated trackers" do 
		bo = ArcBlackoutDate.first
		city = bo.arc_city_states.first
		all = ArcBlackoutTracker.count
		before = ArcBlackoutDate.count
		before2 = bo.arc_blackout_trackers.count 
		delete "/arc/api/blackout-dates/#{bo.id}?all=false&city_id=#{city.id}"
		after = ArcBlackoutDate.count
		expect(after).to eq(before)
		expect(ArcBlackoutTracker.count).to eq(all-1)
	end

	it "DELETE /arc/api/blackout-dates/:id?all=false - should require city ID parameter" do 
		bo = ArcBlackoutDate.first
		city = bo.arc_city_states.first
		delete "/arc/api/blackout-dates/#{bo.id}?all=false"
		expect(json["status"]).to eq(1)
	end

	it "DELETE /arc/api/blackout-dates/:id - respond with status 0 if invalid id" do 
		delete "/arc/api/blackout-dates/adsadsa"
		expect(json["status"]).to eq(1)
	end

	it "should return JSON (/arc/api/blackout-dates/bo_id/switch)" do 
		bo = ArcBlackoutDate.first
		post "/arc/api/blackout-dates/#{bo.id}/switch"
		expect(json).to_not be nil
	end

	it "should allow switching from black to yellow (/arc/api/blackout-dates/bo_id/switch)" do 
		bo = ArcBlackoutDate.first
		city = bo.arc_city_states.first
		bo.update_attributes(date_type: "black")
		post "/arc/api/blackout-dates/#{bo.id}/switch?city_id=#{city.id}"
		expect(json["status"]).to eq(0)
		expect(json["date"]["date_type"]).to eq("yellow")
	end

	it "should allow switching from yellow to black (/arc/api/blackout-dates/bo_id/switch)" do 
		bo = ArcBlackoutDate.first
		city = bo.arc_city_states.first
		bo.update_attributes(date_type: "yellow")
		post "/arc/api/blackout-dates/#{bo.id}/switch?city_id=#{city.id}"
		expect(json["status"]).to eq(0)
		expect(json["date"]["date_type"]).to eq("black")
	end

	it "should return JSON (delete all)" do
		bo = ArcBlackoutDate.first
		delete "/arc/api/blackout-dates/#{bo.id}?all=true"
		expect(json).to_not be nil
	end

	it "should remove all associations between this date and cities" do 
		bo = ArcBlackoutDate.first
		before = bo.arc_blackout_trackers.count
		delete "/arc/api/blackout-dates/#{bo.id}?all=true"
		after = bo.arc_blackout_trackers.count
		expect(json["removed"]).to eq(before-after)
	end

	it "should return json for DELETE arc/api/:id/" do 
		city = ArcCityState.first 
		delete "/arc/api/cities/#{city.id}/"
		expect(json).to_not be nil 
	end

	it "should return error if city not found" do 
		delete "/arc/api/cities/blah/"
		expect(json["status"]).to eq(1)
	end

	it "should remove one city-state" do 
		city = ArcCityState.first
		before = ArcCityState.count 
		delete "/arc/api/cities/#{city.id}/"
		after = ArcCityState.count
		expect(json["status"]).to eq(0)
		expect(after).to eq(before-1)
	end

end