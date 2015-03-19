require 'rails_helper'

RSpec.describe CostPerThousand, type: :model do
  
	it "should not allow blank publications" do 
		cpt = CostPerThousand.new(publications: "")
		expect(cpt.valid?).to eq(false)
		cpt = CostPerThousand.new(publications: nil)
		expect(cpt.valid?).to eq(false)
	end

	it "should not allow blank cost" do 
		cpt = CostPerThousand.new(cost: "")
		expect(cpt.valid?).to eq(false)
		cpt = CostPerThousand.new(cost: nil)
		expect(cpt.valid?).to eq(false)
	end

end
