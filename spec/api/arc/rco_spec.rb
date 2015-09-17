# Tests routes:
# 	match "/arc/api/rco", to: "arc#create_rco", via: [:post, :options] 
# 	match "/arc/api/rcos", to: "arc#get_rcos", via: :get

describe "ARC RCO API", :type => :request do

	before { @params = FactoryGirl.build(:rco_order).attributes.symbolize_keys }

	# for match "/arc/api/rco", to: "arc#create_rco", via: [:post, :options] 
	it "should return json" do 
		post "/arc/api/rco", @params
		expect(json).to_not be nil
	end

	it "should return status 0 with valid rco" do 
		post "/arc/api/rco", @params
		expect(json["status"]).to eq(0)
	end

	it "should return status 1 with invalid rco" do 
		@params[:agent_name] = nil
		post "/arc/api/rco", @params
		expect(json["status"]).to eq(1)
	end

	it "should create a new RCO" do 
		before = RcoOrder.count 
		post "/arc/api/rco", @params
		after = RcoOrder.count 
		expect(after).to eq(before+1)
	end

	# for match "/arc/api/rcos", to: "arc#get_rcos", via: :get
	it "should return json and status should always be 0" do 
		get "/arc/api/rcos"
		expect(json).to_not be nil 
		expect(json["status"]).to eq(0)
	end

	it "should have rcos key" do 
		get "/arc/api/rcos"
		expect(json.has_key?("rcos")).to be true
	end

	it "rcos should not be nil" do 
		get "/arc/api/rcos"
		expect(json["rcos"]).to_not be nil
	end

	it "rcos should be an array" do 
		get "/arc/api/rcos"
		expect(json["rcos"].class.to_s).to eq("Array")
	end

	it "rco should be an array of hashes" do 
		get "/arc/api/rcos"
		expect(json["rcos"][0].class.to_s).to eq("Hash")
	end

end






