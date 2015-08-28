require 'rails_helper'

describe "ARC API", :type => :request do

	before { @create_params = params = { date: "01/01/2015", date_notes: "Notes", 
										yellow: "01/02/2016", yellow_notes: "YNotes", 
										state: {name: "New York", abbreviation: "ny"}, 
										cities: "Suffolk, Nassau, Hornell"
										} 
									}

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

	it "should not pass if date and yellow are nil" do 
		@create_params[:date] = nil 
		@create_params[:yellow] = nil 
		post "/arc/api/blackout-dates", @create_params
		expect(json["status"]).to eq(1) 
	end

	it "should send proper success message" do 
		post "/arc/api/blackout-dates", @create_params
		expect(json["message"]).to eq("3 of 3 saved successfully.")
	end

end




