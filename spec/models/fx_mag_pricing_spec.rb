require 'rails_helper'

RSpec.describe FxMagPricing, type: :model do
  
	it "should require pub id" do 
		mp = FxMagPricing.new(fx_publication_id: nil)
		expect(mp.valid?).to eq(false)
	end

end
