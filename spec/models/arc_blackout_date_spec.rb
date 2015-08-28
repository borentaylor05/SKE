require 'rails_helper'

RSpec.describe ArcBlackoutDate, type: :model do
	include ArcHelper

	before { @date = FactoryGirl.build(:arc_blackout_date) }

	it "should pass with factory arc_blackout_date" do 
		expect(@date).to be_valid
	end

	it "should not allow date and notes to be nil" do 
		@date.date = nil 
		@date.notes = nil 
		expect(@date).to_not be_valid
	end

	it "should pass with blank notes and valid date" do 
		@date.notes = nil 
		expect(@date).to be_valid
	end

	it "should pass with notes and no date" do 
		@date.date = nil 
		expect(@date).to be_valid
	end

	it "should not pass with invalid bo date format" do 
		['asdadasd', '131232132', '1222/2222/2222', '2222/1/2015', '4/444/2015', '12/31/32'].each do |d|
			@date.date = d
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

	it "should not pass with no date type" do 
		@date.date_type = nil 
		expect(@date).to_not be_valid
	end

	it "should require date_type == black or yellow" do 
		@date.date_type = "green"
		expect(@date).to_not be_valid
	end

	it "should pass with yellow date_type" do 
		@date.date_type = "yellow"
		expect(@date).to be_valid
	end

end
