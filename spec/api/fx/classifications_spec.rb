# Fairfax Classification Tool
# Purpose: To make the retrieval of classification codes more efficient.
# This tool contains a set of categories. Each category has many classifications 
# and each classification has a code.  A user launches the tool from the Fairfax Sales app.
# The tool lists all categories and when a user clicks a category, all classifications and codes
# for that category appear. E.g. A user clicks 'AUTOMOTIVE' and sees 'Cars for sale --> CFS'.
# 
# Upload Url: "/fx/upload/classifications"

# This tool is accessed via the Fairfax App in the NZ Sales tab
# To get here, click the app dropdown from the nav menu then click SKE and
# navigate to NZ Sales.
 
# App URL: https://social.teletech.com/apps/2732319e12895194af8d024e7ef623fb

# Models (database entities)
# FxClassCat: app/models/fx_class_cat.rb
# FxClassification: app/models/fx_classification.rb
# 
# FxClassCat Fields:
# t.string   "name"
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false
# 
# FxClassification Fields:
# t.string   "title"
# t.string   "code"
# t.datetime "created_at",      null: false
# t.datetime "updated_at",      null: false
# t.integer  "fx_class_cat_id" --> foreign key to FxClassCat
# 
# Relationships:
# FxClassification belongs_to FxClassCat
# FxClassCat has_many FxClassifications

# Tests routes:
# 	match "/fairfax/deadlines/publication", to: "fx#get_deadlines_by_pub", via: :get  # tested
# 	match "/fairfax/publications", to: "fx#get_pubs", via: :get                       # tested

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
