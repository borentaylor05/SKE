require 'rails_helper'

describe "WW Promotions API", :type => :request do

	it "should have json response" do 
		post "/ww/api/promotions", { ww_promotion: { blah: "ASDSD", signup_date: '1259218800000' } }
		expect(json).to_not eq(nil)
	end

	it "should reject invalid promotion" do 
		post "/ww/api/promotions", { ww_promotion: { blah: "TEST", signup_date: '1259218800000' } }
		expect(json["status"]).to eq(1)
		expect(json["error"]).to_not be_blank
	end

	it "should reject duplicate member_num" do 
		promo = FactoryGirl.create(:ww_promotion)
		post "/ww/api/promotions", { ww_promotion: { first_name: promo.first_name,
													 last_name: promo.last_name,
													 member_num: promo.member_num,
													 gender: promo.gender,
													 billing: promo.billing,
													 state: promo.state,
													 first_name: promo.city,
													 zip: promo.zip,
													 agent_name: promo.agent_name,
													 signup_date: '1259218800000'
													 } 
									}
		expect(json["status"]).to eq(1)
	end

	it "should accept valid promo" do 
		promo = FactoryGirl.create(:ww_promotion)
		post "/ww/api/promotions", { ww_promotion: { first_name: promo.first_name,
													 last_name: promo.last_name,
													 member_num: 1239087,
													 gender: promo.gender,
													 billing: promo.billing,
													 state: promo.state,
													 first_name: promo.city,
													 zip: promo.zip,
													 agent_name: promo.agent_name,
													 signup_date: '1428904800000' # April 13
													 } 
									}
		expect(json["status"]).to eq(0)
	end

end