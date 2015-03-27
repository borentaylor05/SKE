class WwController < ApplicationController
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers

	def create_promotion_entry
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			logger.info(params)
			promo = WwPromotion.new(promo_params)
			if promo.valid? 
				promo.save
				respond({ status: 0, promo: promo })
			else
				respond({ status: 1, error: "#{promo.errors.full_messages}" })
			end
		end
	end

	private

		def promo_params
			params.require(:ww_promotion).permit(:first_name, :last_name, :member_num, :gender, :billing, :city, :state, :zip, :agent_name)
		end

end
