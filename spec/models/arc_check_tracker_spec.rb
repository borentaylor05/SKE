require 'rails_helper'

RSpec.describe ArcCheckTracker, type: :model do
  	
	before { @check = FactoryGirl.build(:arc_check_tracker) }

	it "should pass with valid check" do 
		expect(@check).to be_valid
	end

	it "should not pass without check_num" do 
		@check.check_num = nil 
		expect(@check).to_not be_valid
	end

	it "should not pass without check_date" do 
		@check.check_date = nil 
		expect(@check).to_not be_valid
	end

	it "should not pass without check_amount" do 
		@check.check_amount = nil 
		expect(@check).to_not be_valid
	end
	it "should not pass without case_id" do 
		@check.case_id = nil 
		expect(@check).to_not be_valid
	end
	it "should not pass without check_name" do 
		@check.check_name = nil 
		expect(@check).to_not be_valid
	end
	it "should not pass without state" do 
		@check.state = nil 
		expect(@check).to_not be_valid
	end
	it "should not pass without tsc_received" do 
		@check.tsc_received = nil 
		expect(@check).to_not be_valid
	end

end
