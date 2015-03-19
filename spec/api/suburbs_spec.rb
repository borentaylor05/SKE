require 'rails_helper'

describe "Comments API", :type => :request do

	# For /fx/api/publications -> no params
	it "should be able to access /fx/api/publications" do 
		get "/fx/api/publications"
      	expect(response).to have_http_status(:success)
	end

	it "should return json object with all publication names and ids" do 
		num = FxPublication.count
		get "/fx/api/publications"
		expect(json["status"]).to eq(0)
		expect(json["pubs"]).to_not eq(nil)
		expect(json["pubs"].count).to eq(num)
		expect(json["pubs"][0]["id"]).to_not be nil
		expect(json["pubs"][0]["name"]).to_not be nil
	end
	
	# For /fx/api/publications/:publication_id/suburbs -> { :publication_id }
	it "should return suburbs" do
		id = FxPublication.first.id 
		num = FxPublication.first.suburbs.count
		get "/fx/api/publications/#{id}/suburbs"
		expect(json["status"]).to eq(0)
		expect(json["suburbs"]).to_not eq(nil)
		expect(json["suburbs"].count).to eq(num)
		expect(json["suburbs"][0]["id"]).to_not be nil
		expect(json["suburbs"][0]["name"]).to_not be nil
	end

	it "should fail gracefully with invalid pub id" do 
		id = "gibberish"
		get "/fx/api/publications/#{id}/suburbs"
		expect(json["status"]).to eq(1)
	end

	# For /fx/api/suburbs/:suburb_id/publications
	it "should return publications" do 
		id = Suburb.first.id
		num = Suburb.first.fx_publications.count
		get "/fx/api/suburbs/#{id}/publications"
		expect(json["status"]).to eq(0)
		expect(json["publications"].count).to eq(num)
		expect(json["publications"][0]["id"]).to_not be nil
		expect(json["publications"][0]["name"]).to_not be nil
	end

	it "should fail gracefully with invalid suburb id" do
		id = "gibberish"
		get "/fx/api/suburbs/#{id}/publications"
		expect(json["status"]).to eq(1)
	end

	# for /fx/api/publications/:publication_id/cost-per-thousands 
	it "should fail gracefully with invalid publication_id" do 
		id = "gibberish"
		get "/fx/api/publications/#{id}/cost-per-thousands"
		expect(json["status"]).to eq(1)
	end

	it "should return all costs for publication_id" do 
		id = 157
		get "/fx/api/publications/#{id}/cost-per-thousands"
		expect(json["status"]).to eq(0)
		expect(json["cpts"]).to_not eq(nil)
		expect(json["cpts"].count).to be > 1
	end

end






