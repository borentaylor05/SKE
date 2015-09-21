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
		promo2 = FactoryGirl.build(:ww_promotion)
		promo2.member_num = promo.member_num
		post "/ww/api/promotions", { ww_promotion: promo2.attributes.symbolize_keys }
		expect(json["status"]).to eq(1)
	end

	it "should accept valid promo" do 
		promo = FactoryGirl.build(:ww_promotion).attributes
		post "/ww/api/promotions", { ww_promotion: promo }
		expect(json["status"]).to eq(0)
	end

end