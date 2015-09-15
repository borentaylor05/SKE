require 'rails_helper'

describe "CDC Address Book", :type => :request do

	# Address Book
	# for cdc/address-book, -> {}, via address_book#get_all
	it "should have json response" do 
		get "/cdc/address-book"
		expect(json).to_not be nil
	end

	it "should return valid results" do 
		get "/cdc/address-book"
		expect(json["status"]).to eq(0)
		expect(json[""])
	end

end