require 'rails_helper'

describe "CDC A to Z List", :type => :request do

	# for /cdc/api/search -> { search: searchTerm }
	it "should return json" do 
		get "/cdc/api/search"
		expect(json).to_not be nil
	end

	it "should require search parameter" do 
		get "/cdc/api/search"
		expect(json["status"]).to eq(1)
	end

	it "should respond with valid results when passed valid search term" do 
		get "/cdc/api/search", { search: "hiv" }
		expect(json["status"]).to eq(0)
		expect(json["topics"].count).to be > 0
	end

	# for /cdc/api/get-range -> { start: 'A', end: 'D' }
	it "should have json response" do 
		get "/cdc/api/get-range"
		expect(json).to_not be nil
	end

	it "should require :start and :end params" do 
		get "/cdc/api/get-range"
		expect(json["status"]).to eq(1)
		expect(json["error"]).to eq("Must supply :start and :end parameter.")
	end

	it "should return valid results" do 
		get "/cdc/api/get-range", { start: "W", end: "Z" }
		expect(json["status"]).to eq(0)
		expect(json["topics"].count).to be > 0
	end

	# for /cdc/api/topic -> { id: AToZEntry.id }
	it "should have json response" do 
		get "/cdc/api/topic"
		expect(json).to_not be nil
	end

	it "should require id" do 
		get "/cdc/api/topic"
		expect(json["status"]).to eq(1)
	end

	it "should return valid topic object" do 
		id = AToZEntry.first.id
		get "/cdc/api/topic", { id: id } 
		expect(json["status"]).to eq(0)
		expect(json["topic"]["topic"]).to_not be nil
	end

end