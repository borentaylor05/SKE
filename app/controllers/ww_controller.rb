class WwController < ApplicationController
	include ActionView::Helpers::DateHelper
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers

	def create_promotion_entry
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			promo = WwPromotion.new(
				first_name: params[:ww_promotion][:first_name],
				last_name: params[:ww_promotion][:last_name],
				member_num: params[:ww_promotion][:member_num],
				billing: params[:ww_promotion][:billing],
				city: params[:ww_promotion][:city],
				state: params[:ww_promotion][:state],
				zip: params[:ww_promotion][:zip],
				agent_name: params[:ww_promotion][:agent_name],
				description: params[:ww_promotion][:description],
				member_phone: params[:ww_promotion][:member_phone],
				meet_city: params[:ww_promotion][:meet_city],
				meet_state: params[:ww_promotion][:meet_state]
			)
			if promo.valid? 
				promo.save				
				respond({ status: 0, promo: promo })				
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

	def get_oprah_code
		logger.info request
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			tracker = WwOprahTracker.new({
					caller_issue: params[:caller_issue],
					referral_type: params[:referral_type],
					member_sub: params[:member_sub],
					non_working_code: params[:non_working_code],
					signup_date: params[:signup_date],
					referral_location: params[:referral_location]
				})
			if tracker.valid?
				code = WwOprahCode.find_by(used: false)
				if code
					code.update_attributes(used: true)
					respond({ status: 0, message: 'Success', code: code.code })
				else
					respond({ status: 1, message: 'All codes have been used', error: tracker.errors.full_messages })
				end
			else
				respond({ status: 1, message: 'Invalid tracker info', error: tracker.errors.full_messages })
			end	
		end
	end

	private

		def promo_params
			params.require(:ww_promotion).permit(:first_name, :last_name, :member_num, :billing, :city, :state, :zip, :agent_name, :member_phone, :meet_state, :meet_city, :description)
		end

		def check_time(promo)
			s = Date.strptime('04-12-2015', '%m-%d-%Y') # start
			e = Date.strptime('04-27-2015', '%m-%d-%Y') # end
			ship_time = 14
			if !promo.nonqual and !promo.signup_date.between?(s,e)
				return "Thanks for your interest in our promotional kit.  Unfortunately, this promotion is only available to members who sign up for a subscription plan between 4/12 and 4/27.  You may purchase a kit from your meeting location."
			elsif !promo.nonqual and (Date.today - promo.signup_date).to_i <= ship_time
				return "Your promotion kit may take up to 14 days to arrive.  If you have not received your kit by #{(promo.signup_date + 15.days).strftime("%D")}, please give us a call back and we can ship you a replacement kit."
			else
				return 1 
			end
		end

end
