class CodesController < ApplicationController
	include ActionView::Helpers::DateHelper
	skip_before_action :verify_authenticity_token
#	before_action :access_check
	after_filter :cors_set_access_control_headers
	after_action :allow_iframe
	
	#NOTE: here is where I started using status numbers correctly, i.e. 0 = success, 1 = error

	def new
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			i = WwCodeInfo.new(
				sub_num: params[:sub],
				member_first_name: params[:member_first].downcase,
				member_last_name: params[:member_last].downcase,
				member_zip: params[:zip],
				agent_id: params[:agent_id], #this is their Jive API ID
				agent_name: params[:agent_name].downcase,
				token: generate_token(10),
				description: params[:desc],
				requesting_type: params[:type]
			)

			if i.valid?
				i.save
				resp = { status: 0, token: i.token }
			else
				Rails.logger.debug("#{i.errors.full_messages}")
				resp = { status: 1, message: i.errors.full_messages }
			end
			respond(resp)
		else
			respond({})
		end
	end

	def get_info
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			if WwCodeInfo.exists?(token: params[:token])
				info = WwCodeInfo.find_by(token: params[:token])
				if info.used
					respond({ status: 1, error: "This token has already been through the approval process." })
				else
					info.update_attributes(used: true)
					respond({status: 0, content: info})
				end
			else
				respond(status: 1, error: "Token does not exist.")
			end
		else
			respond({})
		end
	end

	def get_code
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			info = WwCodeInfo.find_by(token: params[:token])
			if info
			#	info = WwCodeInfo.find_by(token: params[:token])
				c = get_unused_code(params[:type])
				if c[:status] == 0
					c[:code].update_attributes(
						date_assigned: Time.now,
						assigned_by: params[:agent_id],
						assigned_by_name: params[:agent_name].downcase,
						ww_code_info: info,
						used: true
					)
					if c[:code].valid?
						c[:code].save
					else
						respond({ status: 1, message: "#{code.errors.full_messages}" })
					end
					info.update_attributes(ww_code_id: c[:code].id, reviewed_by: params[:agent_name].downcase)
				end
				respond(c)
			else
				respond({status: 1, error: "Token does not exist."})
			end
		else
			respond(params)
		end
	end

	def get_all
		Rails.logger.info()
		if params.has_key?("status")
			codes = get_results(WwCode.where(used: params[:status]))
		elsif params.has_key?("key")
			case params[:key]
				when "assigning"
					codes = get_results(WwCode.where(assigned_by_name: params[:value].downcase))
				when "requesting"
					c = []
					WwCodeInfo.where(agent_name: params[:value].downcase).where.not(ww_code_id: nil).each do |w|
						c.push(w.ww_code)
					end
					codes = get_results(c)
				when "code"
					codes = get_results(WwCode.where(code_num: params[:value]))
				when "token"
					codes = [] # only bc get_results expects array
					if WwCodeInfo.exists?(token: params[:value])
						codes.push(WwCodeInfo.find_by(token: params[:value]).ww_code)
						codes = get_results(codes)
					end
			end
		else
			codes = get_results(WwCode.all)
		end
		if codes.count > 0
			respond({ status: 0, content: codes, amounts: get_unused_amounts })
		else
			respond({ status: 1, amounts: get_unused_amounts, error: "There are no matching codes in the database." })
		end
	end

	def get_people
		respond({ 
			# Both get unique values, first way didn't interfere with my model order, second way did
			assigning_agents: WwCode.select(:assigned_by_name).map(&:assigned_by_name).uniq,
			requesting_agents: WwCodeInfo.uniq.pluck(:agent_name),
			amounts: get_unused_amounts
		})
	end

	def proxy
	end

	def load
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			amounts = []
			errors = []
			valid = ["42.95", "39.95", "lifetime"]
			params.each do |key, array|
				if valid.include?(key)
					hash = { name: key, amount: 0 }
					array.each do |code|
						w = WwCode.new(
							code_num: code,
							code_type: key
						)
						if w.valid?
							w.save
							hash[:amount] = hash[:amount] + 1
						else
							errors.push({ code: code, error: w.errors.full_messages });
						end
					end
					amounts.push(hash)
				end
			end
			respond({ status: 0, amounts: amounts, errors: errors })
		end
	end

	def toggle
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			if WwCode.exists?(code_num: params[:code])
				code = WwCode.find_by(code_num: params[:code])
				info = code.ww_code_info
				if params[:to_status] == false
					code.update_attributes(used: params[:to_status])
					info.update_attributes(agent_id: nil, agent_name: nil)
				else
					code.update_attributes(used: params[:to_status])
					info.update_attributes(agent_name: "From Admin Console", agent_id: 0)
				end
				respond({ status: 0, message: "Changed Status" })
			else
				respond({ status: 1, error: "Code does not exist" })
			end
		end
	end

	private

		def get_unused_code(type)
			if get_number_unused(type) == 0
				Rails.logger.info("NUMBER: #{get_number_unused(type)}")
				return { status: 1, content: { message: "There are no more codes of this type:", type: type } }
			else
				return { status: 0, code: WwCode.where(code_type: type, used: false).first, amounts: get_unused_amounts }
			end
		end

		def get_number_unused(type)
			num = WwCode.where(code_type: type, used: false).count
			return num
		end

		def get_unused_amounts
			return [
				{ name: "42.95", unused: WwCode.where(code_type: "42.95", used: false).count },
				{ name: "39.95", unused: WwCode.where(code_type: "39.95", used: false).count },
				{ name: "Lifetime", unused: WwCode.where(code_type: "lifetime", used: false).count }
			]
		end

		# returns max 100 results
		def get_results(search)
			codes = []
			count = 0
			search.each do |c|
				hash = c.attributes
				if c.used
					hash[:assigned_readable] = "#{time_ago_in_words(c.date_assigned)} ago"
					hash[:info] = WwCodeInfo.find_by(ww_code: c)
				end
				codes.push(hash)
				count = count + 1
				if count == 100
					break
				end
			end
			return codes
		end

end
