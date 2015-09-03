require 'rails_helper'

describe "ARC API", :type => :request do

	before { @create_params = { date: "01/01/2015", date_notes: "Notes", 
										yellow: "01/02/2016", yellow_notes: "YNotes", 
										state: {name: "New York", abbreviation: "ny"}, 
										cities: "Suffolk, Nassau, Hornell"
										} 
									}
	before { @group_params = { cities: "Suffolk, Nassau, Hornell", state: "NY", name: "TEST" } }

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

	it "POST /arc/api/blackout-dates/group - pass with blank backout date" do 
		@group_params[:date] = ""
		@group_params[:yellow] = "09/23/2015"
		post "/arc/api/blackout-dates/group", @group_params
		expect(json["status"]).to eq(0)
	end

	it "POST /arc/api/blackout-dates/group - pass with blank yellow date" do 
		@group_params[:date] = "09/23/2015"
		@group_params[:yellow] = ""
		post "/arc/api/blackout-dates/group", @group_params
		expect(json["status"]).to eq(0)
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
		id = ArcBlackoutDate.first.id
		delete "/arc/api/blackout-dates/#{id}"
		expect(json["status"]).to eq(0)
	end

	it "DELETE /arc/api/blackout-dates/:id - should delete BO Date and associated trackers" do 
		id = ArcBlackoutDate.first.id
		bo = ArcBlackoutDate.find_by(id: id)
		before = ArcBlackoutDate.count
		all = ArcBlackoutTracker.count
		before2 = bo.arc_blackout_trackers.count 
		delete "/arc/api/blackout-dates/#{id}"
		after = ArcBlackoutDate.count
		expect(after).to eq(before-1)
		expect(ArcBlackoutTracker.count).to eq(all-before2)
	end

	it "DELETE /arc/api/blackout-dates/:id - respond with status 0 if invalid id" do 
		delete "/arc/api/blackout-dates/adsadsa"
		expect(json["status"]).to eq(1)
	end

end




