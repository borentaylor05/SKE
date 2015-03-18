require 'rails_helper'

RSpec.describe Suburb, type: :model do
  
	it "Should not allow blank name" do 
		p = Suburb.new(name: "")
		expect(p.valid?).to eq(false)
	end

	it "should not allow nil name" do 
		p = Suburb.new(name: nil)
		expect(p.valid?).to eq(false)
	end

	it "should allow valid name" do 
		p = Suburb.new(name: "TEST")
		expect(p.valid?).to eq(true)
	end

end
