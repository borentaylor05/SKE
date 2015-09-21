# CDC A to Z List
# Purpose: Agents can retrieve all entries in the list and get all info for each topic.
# The list is given to Ivan and he uploads it via Heroku at http://lit-inlet-2632.herokuapp.com/cdc/upload/a-to-z

# This tool is accessed via the CDC App
# To get to the CDC app, you must be in the security group called 'CDCKB'
# If you are in this group you should see an extra tab called 'Knowledge Base' in every space
# Clicking that tab will open a page with this and many other tools for CDC
 
# URLs: you can access through any space, but if you don't want to do that, use this:
# https://social.teletech.com/community/clients/verizon-networkx/cdc-centers-for-disease-control/cdc-knowledge-base/apps/4ed8a357e2ba52799893425ee1733717/cdc

# Models (database entities)
# AToZEntry: app/models/a_to_z_entry.rb
# 
# AToZEntry Fields:
# t.string   "topic"
# t.string   "aka"
# t.string   "owner"
# t.string   "scope"
# t.string   "notes"
# t.string   "program_flow"
# t.string   "cdc_link"
# t.datetime "created_at",   null: false
# t.datetime "updated_at",   null: false
# t.boolean  "pr"
# t.boolean  "spanish"

# Tests routes:
# 	match "/cdc/api/search", to: "a_to_z#cdc_search", via: :get     # tested
# 	match "/cdc/api/get-range", to: "a_to_z#get_range", via: :get   # tested
# 	match "/cdc/api/topic", to: "a_to_z#get_topic", via: :get       # tested

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
		get "/cdc/api/get-range?start=A&end=Z"
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

	it "should return Z entries" do 
		get "/cdc/api/get-range", { start: "W", end: "Z" }
		expect(json["status"]).to eq(0)
		expect(json["topics"].last["topic"][0]).to eq("Z")
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