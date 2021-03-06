require 'rails_helper'

describe "Suburbs API", :type => :request do

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
		id = FxPublication.find_by(name: "Nor-West News").id
		num = FxPublication.find_by(name: "Nor-West News").suburbs.count
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

	# for /fx/api/suburbs/search?term=:searchTerm 
	it "should fail gracefully if no :searchTerm provided" do 
		get "/fx/api/suburbs/search"
		expect(json["status"]).to eq(1)
		expect(json["error"]).to_not be_blank
	end

	it "should fail gracefully if searchTerm is empty" do 
		st = ""
		get "/fx/api/suburbs/search?term=#{st}"
		expect(json["status"]).to eq(1)
		expect(json["error"]).to_not be_blank
	end

	it "return empty array if no results are found but searchTerm exists" do 
		st = "dsfdsfdsfdsfdfsdfdsfggdd"
		get "/fx/api/suburbs/search?term=#{st}"
		expect(json["status"]).to eq(0)
		expect(json["matches"]).to be_empty
	end

	it "should return valid results if valid suburb" do 
		st = "Linden"
		get "/fx/api/suburbs/search?term=#{st}"
		expect(json["status"]).to eq(0)
		expect(json["matches"]).to_not be_empty
	end

end
