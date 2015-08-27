class ArcController < ApplicationController

	include ActionView::Helpers::DateHelper
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers
	after_action :allow_iframe

	def get_checks
		if params.has_key?("search")
			if numeric?(params["search"])
				respond({ status: 0, checks: apify(ArcCheckTracker.search_numeric(params[:search]).limit(25), $eastern_tz) })
			else
				respond({ status: 0, checks: apify(ArcCheckTracker.search_string(params[:search]).limit(25), $eastern_tz) })
			end			
		elsif params.has_key?("name")
			respond({ status: 0, checks: apify(ArcCheckTracker.where(agent_name: params[:name]).limit(25), $eastern_tz) })
		else
			respond({ status: 0, checks: apify(ArcCheckTracker.where(["updated_at > ?", 2.days.ago]), $eastern_tz) })
		end
	end

	def update_check
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			check = ArcCheckTracker.find_by(id: params[:check_id])
			if check
				check.update_attributes(
					check_num: params[:check_num],
					check_date: params[:check_date],
					check_amount: params[:check_amount],
					case_id: params[:case_id],
					org: params[:org],
					check_name: params[:check_name],
					state: params[:state],
					tsc_received: params[:tsc_received],
					order_num: params[:order_num],
					crs: params[:crs],
					notes: params[:notes],
					sent_back_by: params[:sent_back_by],
					agent_name: params[:agent_name]
				)
				respond({ status: 0, check: check })
			else
				respond({ status: 1, error: "Check not found. Contact Nicole Nordlund." })		
			end
		end
	end

	def get_check_agents
		respond({ status: 0, agents: ArcCheckTracker.find_by_sql("SELECT DISTINCT agent_name FROM arc_check_trackers") })
	end

	def create_check
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			check = ArcCheckTracker.new(
				check_num: params[:check_num],
				check_date: params[:check_date],
				check_amount: params[:check_amount],
				case_id: params[:case_id],
				org: params[:org],
				check_name: params[:check_name],
				state: params[:state][:abbreviation],
				tsc_received: params[:tsc_received],
				order_num: params[:order_num],
				crs: params[:crs],
				notes: params[:notes],
				sent_back_by: params[:sent_back_by],
				agent_name: params[:agent_name]
			)
			if check.valid?
				check.save
				respond({ status: 0, check: check })
			else
				respond({ status: 1, error: check.errors.full_messages })
			end
		end
	end

	def get_blackout_dates
		city = ArcCityState.find_by(city: params[:city], state: State.find_by(name: params[:state]))
		if city
			respond({ status: 0, dates: city.arc_blackout_dates })
		else
			respond({ status: 1, error: "City / State combo not found..." })
		end
	end

	def get_all_cities
		respond({ status: 0, cities: city_states(ArcCityState.all) })
	end

	def check_cities
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			cities = []
			params[:cities].each do |c|
				c = c.strip
				city = ArcCityState.find_by(city: c.downcase, state: State.find_by(abbreviation: params[:state].upcase))
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
			errors = []
			created = 0
			duplicate = 0			
			bo = ArcBlackoutDate.find_by(date: params[:date], notes: params[:notes])
			if !bo
				begin 
					expires = parse_arc_bo_date(params[:date])
					expires_yellow = parse_arc_bo_date(params[:notes])
					bo = ArcBlackoutDate.new(date: params[:date], notes: params[:notes], expires: expires, expires_yellow: expires_yellow)
				rescue ArgumentError, TypeError
					bo = ArcBlackoutDate.new(date: params[:date], notes: params[:notes])
					errors.push "Invalid Date: #{params[:date]}"
				end				
				if bo.valid?
					bo.save	
				else
					Rails.logger.info bo.errors.full_messages 
				end	
			end			
			cities.each do |c|
				c = c.strip if c
				city = ArcCityState.find_by(city: c.downcase, state: State.find_by(abbreviation: params[:state][:abbreviation].upcase))
				if !city 
					city = ArcCityState.new(city: c.downcase, state: State.find_by(abbreviation: params[:state][:abbreviation].upcase))
					if city.valid?
						city.save							
					else
						Rails.logger.info city.errors.full_messages 
					end
				end
				if !ArcBlackoutTracker.exists?(arc_city_state: city, arc_blackout_date: bo)
					tracker = ArcBlackoutTracker.new( arc_city_state: city, arc_blackout_date: bo )
					if tracker.valid?
						tracker.save
						created += 1
					else
						Rails.logger.info tracker.errors.full_messages 
					end
				else
					duplicate +=1
				end
			end
			respond({ status: 0, message: "#{created} of #{base} saved successfully.", duplicate: duplicate, errors: errors })
		end
	end

	def get_rcos
		respond({ status: 0, rcos: apify(RcoOrder.where(["created_at > ?", 2.days.ago]), $eastern_tz) })
	end

	def create_rco
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
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

	private

		def parse_arc_bo_date(date_string)
			if date_string.include?("-")
				start, date_string = date_string.split("-")  
			end
			expires = date_string ? Date.strptime(date_string, '%m/%d/%Y') : nil
			return expires
		end

		def city_states(cities)
			combo = []
			cities.each do |c|
				hash = c.attributes
				hash[:state] = c.state.name
				combo.push(hash)
			end
			return combo
		end

end
