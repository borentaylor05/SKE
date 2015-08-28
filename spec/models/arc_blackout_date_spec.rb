require 'rails_helper'

RSpec.describe ArcBlackoutDate, type: :model do
	include ArcHelper

	before { @date = FactoryGirl.build(:arc_blackout_date) }

	it "should pass with factory arc_blackout_date" do 
		expect(@date).to be_valid
	end
  	
	it "should not pass with blank black and yellow dates" do 
		@date.date = nil
		@date.notes = nil 
		expect(@date).to_not be_valid
	end

	it "should allow date or notes to be nil" do 
		@date.notes = nil
		expect(@date).to be_valid
	end

	it "should allow date or notes to be nil" do 
		@date.date = nil
		expect(@date).to be_valid
	end

	it "should not let expires_yellow and expires to be nil" do 
		@date.expires = nil 
		@date.expires_yellow = nil
	end

	it "should not pass with invalid bo date format" do 
		['asdadasd', '131232132', '1222/2222/2222', '2222/1/2015', '4/444/2015', '12/31/32'].each do |d|
			@date.date = d
			expect(@date).to_not be_valid
		end
	end

	it "should not pass with invalid yellow date format" do 
		['asdadasd', '131232132', '1222/2222/2222', '2222/1/2015', '4/444/2015', '12/31/32', '12/2/2021', '3/2/2000', '12/12/2015-kjhkjh', '12/12/2015-02/01/87'].each do |d|
			@date.notes = d
			expect(@date).to_not be_valid
		end
	end

	it "should accept valid date string" do 
		['9/12/2015', '09/02/2015', '08/12/2015', '04/12/2015-08/12/2015', '04/02/2017'].each do |d|
			@date.date = d
			expect(@date).to be_valid
		end
	end

	it "should not pass with date and no expires" do 
		@date.expires = nil 
		expect(@date).to_not be_valid
	end

	it "should not pass with notes (yellow date) and no expires_yellow" do 
		@date.expires_yellow = nil 
		expect(@date).to_not be_valid
	end

	it "should allow both date and expires to be nil" do 
		@date.date = nil 
		@date.expires = nil 
		expect(@date).to_not be_valid
	end

	it "should allow both notes (yellow date) and expires_yellow to be nil" do 
		@date.notes = nil 
		@date.expires_yellow = nil 
		expect(@date).to_not be_valid
	end

end
