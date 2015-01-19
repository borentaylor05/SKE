class CodesController < ApplicationController
	include ActionView::Helpers::DateHelper
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers
	after_action :allow_iframe
	#NOTE: here is where I started using status numbers correctly, i.e. 0 = success, 1 = error

	def new
		if(request.method == "OPTIONS")
			respond({status: 0})
		elsif request.method == "POST"
			i = WwCodeInfo.new(
				sub_num: params[:sub],
				member_first_name: params[:member_first],
				member_last_name: params[:member_last],
				member_zip: params[:zip],
				agent_id: params[:agent_id], #this is there Jive API ID
				agent_name: params[:agent_name],
				token: generate_token,
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
					respond({ status: 1, error: "Token has already been used. Ask agent to generate another." })
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
			if WwCodeInfo.find_by(token: params[:token])
				info = WwCodeInfo.find_by(token: params[:token])
				c = get_unused_code(params[:type])
				if c[:status] == 0
					c[:code].update_attributes(
						date_assigned: Time.now,
						assigned_by: params[:agent_id],
						assigned_by_name: params[:agent_name],
						used: true
					)
					if c[:code].valid?
						c[:code].save
					else
						respond({ status: 1, message: "#{code.errors.full_messages}" })
					end
					info.update_attributes(ww_code_id: c[:code].id)
				end
				respond(c)
			else
				respond({status: 1, error: "Token does not exist."})
			end
		else
			respond({})
		end
	end

	def get_all
		Rails.logger.info()
		if params.has_key?("status")
			codes = get_results(WwCode.where(used: params[:status]))
		elsif params.has_key?("key")
			case params[:key]
				when "assigning"
					codes = get_results(WwCode.where(assigned_by_name: params[:value]))
				when "requesting"
					c = []
					WwCodeInfo.where(agent_name: params[:value]).where.not(ww_code_id: nil).each do |w|
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
			assigning_agents: WwCode.uniq.pluck(:assigned_by_name), 
			requesting_agents: WwCodeInfo.uniq.pluck(:agent_name),
			amounts: get_unused_amounts
		})
	end

	def proxy
	end

	private

		def generate_token
			token = Digest::SHA1.hexdigest([Time.now, rand].join)[0...10]
			while WwCodeInfo.exists?(token: token)
				token = Digest::SHA1.hexdigest([Time.now, rand].join)[0...10]
			end
			return token
		end

		def get_unused_code(type)
			if get_number_unused(type) == 0
				Rails.logger.info("NUMBER: #{get_number_unused(type)}")
				return { status: 1, content: { message: "There are no more codes of this type:", type: type } }
			else
				return { status: 0, code: WwCode.where(code_type: type, used: false).first }
			end
		end

		def get_number_unused(type)
			num = WwCode.where(code_type: type, used: false).count
			return num
		end

		def allow_iframe
			response.headers.except! 'X-Frame-Options'
		end

		def get_unused_amounts
			return [
				{ name: "42.95", unused: WwCode.where(code_type: "42.95", used: false).count },
				{ name: "39.95", unused: WwCode.where(code_type: "39.95", used: false).count },
				{ name: "Lifetime", unused: WwCode.where(code_type: "lifetime", used: false).count }
			]
		end

		# returns max 500 results
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
				if count == 500
					break
				end
			end
			return codes
		end

end
