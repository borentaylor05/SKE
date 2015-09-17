require 'rails_helper'

RSpec.describe RcoOrder, type: :model do

	before { @rco = FactoryGirl.build(:rco_order) }

	it "should be valid with required params" do 
		expect(@rco).to be_valid
	end

	it "should not be valid with null agent_name" do 
		@rco.agent_name = nil 
		expect(@rco).to_not be_valid
	end

	it "should allow duplicate order_id" do 
		dup = @rco.dup 
		@rco.save
		expect(dup).to be_valid
	end

	it "should be in order descending by updated_at" do 
		dup = @rco.dup 
		@rco.save
		dup.agent_name = 'You'
		dup.save
		expect(RcoOrder.all.index(dup)).to be < RcoOrder.all.index(@rco)
	end

end
