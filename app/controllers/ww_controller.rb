class WwController < ApplicationController
	include ActionView::Helpers::DateHelper
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers

	def create_promotion_entry
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			sud = Date.strptime(params[:ww_promotion][:signup_date].to_s,'%Q')			
			promo = WwPromotion.new(
				first_name: params[:ww_promotion][:first_name],
				last_name: params[:ww_promotion][:last_name],
				member_num: params[:ww_promotion][:member_num],
				gender: params[:ww_promotion][:gender],
				billing: params[:ww_promotion][:billing],
				first_name: params[:ww_promotion][:city],
				state: params[:ww_promotion][:state],
				zip: params[:ww_promotion][:zip],
				agent_name: params[:ww_promotion][:agent_name],
				signup_date: sud
			)
			if params.has_key?("nonqual") and params["nonqual"]
				promo.nonqual = true
			else
				promo.nonqual = false
			end
			if promo.valid? 
				promo.save
				result = check_time(promo) 
				if result == 1
					respond({ status: 0, promo: promo })
				else
					promo.update_attributes(member_num: nil, invalid_promo: true)
					respond({ status: 1, error: result })
				end
			else
				if promo.errors.full_messages.include?("Member num has already been taken")
					p = WwPromotion.find_by(member_num: params[:ww_promotion][:member_num])
					respond({ status: 1, type: 'duplicate', error: "This member's request was submitted #{time_ago_in_words(p.created_at)} ago." })
				else
					respond({ status: 1, error: "#{promo.errors.full_messages}" })
				end
			end
		end
	end

	private

		def promo_params
			params.require(:ww_promotion).permit(:first_name, :last_name, :member_num, :gender, :billing, :city, :state, :zip, :agent_name, :signup_date, :nonqual)
		end

		def check_time(promo)
			s = Date.strptime('04-12-2015', '%m-%d-%Y') # start
			e = Date.strptime('04-27-2015', '%m-%d-%Y') # end
			ship_time = 14
			if !promo.nonqual and !promo.signup_date.between?(s,e)
				return "Thanks for your interest in our promotional kit.  Unfortunately, this promotion is only available to members who sign up for a subscription plan between 4/12 and 4/27.  You may purchase a kit from your meeting location."
			elsif (Date.today - promo.signup_date).to_i <= ship_time
				return "Your promotion kit may take up to 14 days to arrive.  If you have not received your kit by #{(promo.signup_date + 15.days).strftime("%D")}, please give us a call back and we can ship you a replacement kit."
			else
				return 1 
			end
		end

end
