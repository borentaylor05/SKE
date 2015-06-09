class ArcController < ApplicationController

	include ActionView::Helpers::DateHelper
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers

	def create_rco
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			rco = RcoOrder.find_by(order_id: params[:order_id])
			if rco 
				respond({ status: 1, error: "RCO with that Order number already exists." })
			else
				rco = RcoOrder.new(
					order_id: params[:order_id],
					agent_name: params[:agent_name],
					created: params[:created] ? true : false,
					acct_with_password: params[:acct_with_password] ? true : false,
					acct_forgot_password: params[:acct_forgot_password] ? true : false,
					no_share: params[:no_share] ? true : false,
					order_id: params[:order_id],
					lms_num: params[:lms_num],
					num_registrations: params[:num_registrations],
					coupon: params[:coupon],
					paypal: params[:paypal] ? true : false,
					knows_lms: params[:knows_lms] ? true : false,
					need_dir: params[:need_dir] ? true : false,
					attch_sent: params[:attch_sent] ? true : false,
					comments: params[:comments]
				)
				if rco.valid?
					rco.save
					respond({ status: 0, rco: rco })
				else
					respond({ status: 1, error: rco.errors.full_messages })
				end
			end
		end
	end

end
