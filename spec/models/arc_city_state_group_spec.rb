require 'rails_helper'

RSpec.describe ArcCityStateGroup, type: :model do
  
	before { @group = FactoryGirl.build(:arc_city_state_group) }

	it "should pass with factory" do 
		expect(@group).to be_valid
	end

	it "should require a name" do 
		@group.name = nil 
		expect(@group).to_not be_valid
	end

	it "should require a state_id" do 
		@group.state_id = nil 
		expect(@group).to_not be_valid
	end

end
