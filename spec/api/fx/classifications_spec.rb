require 'rails_helper'

describe "Fairfax Classifications API", :type => :request do

	# BEGIN Classifications Tests
	# match "/fx/classifications", to: "fx_classification#get_classifications", via: :get  \
	

	
	it "should return JSON" do 
		get "/fx/classifications"
		expect(json).to_not be nil
	end

	it "should return status 0 with valid cat request" do 
		cc = FxClassCat.first
		get "/fx/classifications?cat=#{cc.id}"
		expect(json["status"]).to eq(0)
	end

	it "should return status 0 with valid search request" do 
		cc = FxClassCat.first
		get "/fx/classifications?search=ackn"
		expect(json["status"]).to eq(0)
	end

	it "should return status 1 with invalid request" do 
		cc = FxClassCat.first
		get "/fx/classifications?cat=jkshjkh"
		expect(json["status"]).to eq(1)
	end

	it "should return status 1 with no cat or search param" do 
		cc = FxClassCat.first
		get "/fx/classifications"
		expect(json["status"]).to eq(1)
	end

	it "should return key `c`" do 
		cc = FxClassCat.first
		get "/fx/classifications?cat=#{cc.id}"
		expect(json.has_key?("c")).to be true 
	end

	it "should return key `c` for search" do 
		cc = FxClassCat.first
		get "/fx/classifications?search=ackn"
		expect(json.has_key?("c")).to be true 
	end


 
	# END Classifications Tests

end
