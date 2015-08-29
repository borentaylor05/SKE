require 'rails_helper'

RSpec.describe ArcGroupTracker, type: :model do

	before { @group = ArcCityStateGroup.create!(name: "TEST", state: State.first) }
	before { @tracker = ArcGroupTracker.new(arc_city_state_id: ArcCityState.first.id, 
												arc_city_state_group_id: @group.id
											)}

	it "should pass with default" do 
		expect(@tracker).to be_valid
	end

	it "should not pass without group" do 
		@tracker.arc_city_state_group = nil 
		expect(@tracker).to_not be_valid
	end

	it "should not pass without city / state" do 
		@tracker.arc_city_state = nil 
		expect(@tracker).to_not be_valid
	end

end
