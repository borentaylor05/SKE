# CDC A to Z List
# Purpose: Agents can easily access their address book which was previously only available in 
# an Excel spreadsheet. 

# This tool is accessed via the CDC App
# To get to the CDC app, you must be in the security group called 'CDCKB'
# If you are in this group you should see an extra tab called 'Knowledge Base' in every space
# Clicking that tab will open a page with this and many other tools for CDC
 
# URLs: you can access through any space, but if you don't want to do that, use this:
# https://social.teletech.com/community/clients/verizon-networkx/cdc-centers-for-disease-control/cdc-knowledge-base/apps/4ed8a357e2ba52799893425ee1733717/cdc

# Models (database entities)
# AddressBookEntry: app/models/address_book_entry.rb
# 
# AddressBookEntry Fields:
# t.string   "ProgramDescription"
# t.string   "AlternateTopicName"
# t.string   "Owner"
# t.string   "LastName"
# t.string   "FirstName"
# t.string   "EmailAddress"
# t.string   "WorkPhone"
# t.string   "CommentText"
# t.datetime "created_at",         null: false
# t.datetime "updated_at",         null: false

# Tests routes:
# 	match "/cdc/api/search", to: "a_to_z#cdc_search", via: :get     # tested
# 	match "/cdc/api/get-range", to: "a_to_z#get_range", via: :get   # tested
# 	match "/cdc/api/topic", to: "a_to_z#get_topic", via: :get       # tested

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