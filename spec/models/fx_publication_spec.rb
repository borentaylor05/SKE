require 'rails_helper'

RSpec.describe FxPublication, type: :model do
  
	it "Should not allow blank name" do 
		p = FxPublication.new(name: "")
		expect(p.valid?).to eq(false)
	end

	it "should not allow nil name" do 
		p = FxPublication.new(name: nil)
		expect(p.valid?).to eq(false)
	end

	it "should allow valid name" do 
		p = FxPublication.new(name: "TEST")
		expect(p.valid?).to eq(true)
	end

end
