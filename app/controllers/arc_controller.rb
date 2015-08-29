class ArcController < ApplicationController

	include ActionView::Helpers::DateHelper
	include ArcHelper

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
			dates = city.arc_blackout_dates
			black = dates.select { |d| d.date_type == "black" }
			yellow = dates.select { |d| d.date_type == "yellow" }
			respond({ status: 0, black: black, yellow: yellow })
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
				c.strip!
				city = ArcCityState.find_by(city: c.downcase.strip, state: State.find_by(abbreviation: params[:state].upcase))
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
			if valid_dates(params)
				cities = params[:cities].split(",")
				base = cities.size
				errors = []
				created = 0
				bo = ArcBlackoutDate.find_by(date: params[:date], date_type: "black")
				yellow = ArcBlackoutDate.find_by(date: params[:yellow], date_type: "yellow")
				if !bo and params[:date]
					# new_date function in app/helpers/ApplicationHelper
					expires = parse_arc_bo_date(params[:date])
					bo = ArcBlackoutDate.create!(date: params[:date], notes: params[:date_notes], expires: expires, date_type: "black")
				end
				if !yellow and params[:yellow] 
					expires = parse_arc_bo_date(params[:yellow])
					yellow = ArcBlackoutDate.create!(date: params[:yellow], notes: params[:yellow_notes], expires: expires, date_type: "yellow")
				end		
				cities.each do |c|
					c.strip! if c
					city = ArcCityState.find_by(city: c.downcase.strip, state: State.find_by(abbreviation: params[:state][:abbreviation].upcase))
					if !city 
						city = ArcCityState.new(city: c.downcase.strip, state: State.find_by(abbreviation: params[:state][:abbreviation].upcase))
						if city.valid?
							city.save					
						else
							errors.push city.errors.full_messages
						end
					end
					if yellow
						ArcBlackoutTracker.find_or_create_by(arc_city_state: city, arc_blackout_date: yellow) 
						created += 1 if !bo
					end
					if bo 
						ArcBlackoutTracker.find_or_create_by(arc_city_state: city, arc_blackout_date: bo)
						created += 1
					end
				end
				respond({ status: 0, message: "#{created} of #{base} saved successfully.", errors: errors })
			else
				respond({ status: 1, error: "Invalid blackout or yellow date.  Make sure they are in mm/dd/yyyy format. Valid years are 2015-2020." })
			end			
		end
	end

	def get_groups
		if params[:state]
			state = State.find_by(abbreviation: params[:state].upcase)
			if state 
				groups = ArcCityStateGroup.where(state: state)
				respond({ status: 0, groups: groups.map { |g| g.apify } })
			else
				respond({ status: 1, error: "State #{params[:state].upcase} not found." })
			end			
		else
			respond({ status: 1, error: "Must send state param." })
		end
	end

	def new_group
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			if params[:state] and params[:cities] and params[:name]
				cities = params[:cities].split(",")
				if cities.count > 0 and params[:name].length > 0
					state = State.find_by(abbreviation: params[:state].upcase)
					if state 
						group = ArcCityStateGroup.find_or_create_by(name: params[:name].downcase, state: state)
						cities.each do |c|
							city = ArcCityState.find_or_create_by(city: c.downcase.strip, state: state)
							if !ArcGroupTracker.exists?(arc_city_state: city, arc_city_state_group: group)
								group.arc_city_states << city
							end
						end
						respond({ status: 0, group: group })
					else
						respond({ status: 1, error: "State #{params[:state].upcase} not found." })
					end
				else
					respond({ status: 1, error: "Need cities and group name." })
				end
			else
				respond({ status: 1, error: "Need state, cities, and name params." })
			end
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

		def city_states(cities)
			combo = []
			cities.each do |c|
				hash = c.attributes
				hash[:state] = c.state.name
				combo.push(hash)
			end
			return combo
		end

		def get_cities(groups)
			groups.map { |g| g.apify }
		end

		def valid_dates(params)
			if params[:date] or params[:yellow]
				if params[:date] and params[:yellow]
					return true if parse_arc_bo_date(params[:date]) and parse_arc_bo_date(params[:yellow])
				elsif params[:date]
					return true if parse_arc_bo_date(params[:date])
				elsif params[:yellow]
					return true if parse_arc_bo_date(params[:yellow])
				end							
				return false
			else
				return false
			end
		end

end



