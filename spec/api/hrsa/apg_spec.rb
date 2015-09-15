require 'rails_helper'

describe "HRSA APG API", :type => :request do

	# for /hrsa/api/apg/documents/:id
	
	it "should return JSON" do 
		doc = CdcApgDocument.first
		get "/hrsa/api/apg/documents/#{doc.id}"
		expect(json).to_not be nil
	end

	it "should return status 0 with good ID" do 
		doc = CdcApgDocument.first
		get "/hrsa/api/apg/documents/#{doc.id}"
		expect(json["status"]).to eq(0)
	end

	it "should return status 1 with bad ID" do 
		get "/hrsa/api/apg/documents/asdasdsa"
		expect(json["status"]).to eq(1)
	end

	it "should return contain all needed keys" do 
		doc = CdcApgDocument.first
		get "/hrsa/api/apg/documents/#{doc.id}"
		expect(json.has_key?("doc")).to be true
		expect(json.has_key?("categories")).to be true
		expect(json.has_key?("topics")).to be true
	end

	it "should return correct value for all keys" do 
		doc = CdcApgDocument.first
		get "/hrsa/api/apg/documents/#{doc.id}"
		expect(json["doc"]).to_not be nil 
		expect(json["categories"]).to_not be nil 
		expect(json["topics"]).to_not be nil 
	end

	# For /hrsa/api/apg/topics/:id
	
	it "should return JSON" do 
		doc = CdcApgSubheader.first
		get "/hrsa/api/apg/topics/#{doc.id}"
		expect(json).to_not be nil
	end

	it "should return status 0 with good ID" do 
		doc = CdcApgSubheader.first
		get "/hrsa/api/apg/topics/#{doc.id}"
		expect(json["status"]).to eq(0)
	end

	it "should return status 1 with bad ID" do 
		get "/hrsa/api/apg/topics/asdasdsa"
		expect(json["status"]).to eq(1)
	end

	it "should return contain all needed keys" do 
		doc = CdcApgSubheader.first
		get "/hrsa/api/apg/topics/#{doc.id}"
		expect(json.has_key?("topic")).to be true
	end

	it "should return correct value for all keys" do 
		doc = CdcApgSubheader.first
		get "/hrsa/api/apg/topics/#{doc.id}"
		expect(json["topic"]).to_not be nil 
	end

	# For /hrsa/api/apg/categories/:id
	
	it "should return JSON" do 
		doc = CdcApgSection.first
		get "/hrsa/api/apg/categories/#{doc.id}"
		expect(json).to_not be nil
	end

	it "should return status 0 with good ID" do 
		doc = CdcApgSection.first
		get "/hrsa/api/apg/categories/#{doc.id}"
		expect(json["status"]).to eq(0)
	end

	it "should return status 1 with bad ID" do 
		get "/hrsa/api/apg/categories/asdasdsa"
		expect(json["status"]).to eq(1)
	end

	it "should return contain all needed keys" do 
		doc = CdcApgSection.first
		get "/hrsa/api/apg/categories/#{doc.id}"
		expect(json.has_key?("topics")).to be true
	end

	it "should return correct value for all keys" do 
		doc = CdcApgSection.first
		get "/hrsa/api/apg/categories/#{doc.id}"
		expect(json["topics"]).to_not be nil 
	end
	
end







