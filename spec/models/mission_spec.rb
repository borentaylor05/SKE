require 'rails_helper'

RSpec.describe Mission, type: :model do
  	
  	before { @mission = Mission.new(bunchball_name: "Test", badge_url: "Test", folder: "Test", game_type: "Jive", game_id: 1) }

	it "should not allow blank name" do 
		@mission.bunchball_name = nil
		expect(@mission).to_not be_valid
	end

	it "should not allow blank folder" do 
		@mission.folder = nil
		expect(@mission).to_not be_valid
	end

end
