class CodesController < ApplicationController
	include ActionView::Helpers::DateHelper
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers
	
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
				respond(status: 0, content: info)
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

end
