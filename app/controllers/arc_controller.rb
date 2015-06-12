class ArcController < ApplicationController

	include ActionView::Helpers::DateHelper
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers
	after_action :allow_iframe

	def check_cities
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			cities = []
			params[:cities].each do |c|
				city = ArcCityState.find_by(city: c.downcase, state: params[:state].upcase)
				if city 
					resp = { name: c, exists: true }
				else
					resp = { name: c, exists: false }
				end
				cities.push(resp)
			end
			respond({ status: 0, cities: cities })
		end		
	end

	def create_blackout_dates
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			cities = params[:cities].split(",")
			base = cities.size
			created = 0
			cities.each do |c|
				c = c.strip if c
				city = ArcCityState.find_by(city: c.downcase, state: params[:state][:abbreviation].upcase)
				if !city 
					city = ArcCityState.new(city: c.downcase, state: params[:state][:abbreviation].upcase)
					if city.valid?
						city.save
					else
						Rails.logger.info city.errors.full_messages 
					end
				end
				bo = ArcBlackoutDate.new(date: params[:date], notes: params[:notes], arc_city_state: city)
				if bo.valid?
					bo.save
					created += 1
				else
					Rails.logger.info bo.errors.full_messages 
				end
			end
			respond({ status: 0, message: "#{created} of #{base} saved successfully." })
		end
	end

	def get_rcos
		respond({ status: 0, rcos: apify(RcoOrder.where(["created_at > ?", 2.days.ago]), $eastern_tz) })
	end

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
