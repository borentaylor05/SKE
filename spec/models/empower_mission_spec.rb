require 'rails_helper'

RSpec.describe EmpowerMission, type: :model do
 
	before { @emp = EmpowerMission.new(metric_name: "test", target: "122") }

	it "should not allow blank metric_name" do 
		@emp.metric_name = nil
		expect(@emp).to_not be_valid
	end

	it "should not allow blank target" do 
		@emp.target = nil
		expect(@emp).to_not be_valid
	end

	it "should only allow integers for target" do 
		@emp.target = "string"
		expect(@emp).to_not be_valid
	end

end
