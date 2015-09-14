require 'rails_helper'

describe "Fairfax API", :type => :request do
	
	# BEGIN Deadlines Tests
	# For  "/fairfax/deadlines/publication", to: "deadline#get_deadlines_by_pub", via: :get
	
	it "should return JSON" do 
		get "/fairfax/deadlines/publication"
		expect(json).to_not be_nil
	end

	it "should return status 0 with valid pub" do 
		pub = "Auckland%20City%20Harbour" # encoded pub name
		get "/fairfax/deadlines/publication?pub=#{pub}"
		expect(json["status"]).to eq(0)
	end

	it "should have deadlines key and that key should not be nil with valid pub" do 
		pub = "Auckland%20City%20Harbour"
		get "/fairfax/deadlines/publication?pub=#{pub}"
		expect(json.has_key?("deadlines")).to be true
	end

	it "should have deadlines key and that key should not be nil with valid pub" do 
		pub = "Auckland%20City%20Harbour"
		get "/fairfax/deadlines/publication?pub=#{pub}"
		expect(json["deadlines"]).to_not be nil
	end

	it "should have > 0 deadlines" do 
		pub = "Auckland%20City%20Harbour"
		get "/fairfax/deadlines/publication?pub=#{pub}"
		expect(json["deadlines"].count).to be > 0
	end

	it "should return status 1 with no pub param" do 
		pub = "Auckland%20City%20Harbour"
		get "/fairfax/deadlines/publication"
		expect(json["status"]).to eq(1)
	end

	it "should return status 1 with invalid pub name" do 
		pub = "Aasdasdur"
		get "/fairfax/deadlines/publication?pub=#{pub}"
		expect(json["status"]).to eq(1)
	end

	# For match "/fairfax/publications", to: "fx#get_pubs", via: :get
	
	it "should return JSON" do 
		get "/fairfax/publications"
		expect(json).to_not be nil
	end

	it "should return status 0 when pubs / deadlines exist" do 
		get "/fairfax/publications"
		expect(json["status"]).to eq(0)
	end

	it "should have pubs key" do    
		get "/fairfax/publications"
		expect(json.has_key?("pubs")).to be true
	end

	it "should have non nil pubs key" do    
		get "/fairfax/publications"
		expect(json["pubs"]).to_not be nil
	end

	it "should return status 1 if no pubs / deadlines exist" do 
		Deadline.destroy_all 
		get "/fairfax/publications"
		expect(json["status"]).to eq(1)
	end

	# END Deadlines Tests
	# 
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








