class AToZController < ApplicationController
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers
	after_action :allow_iframe
#	before_action :verify

	# gets all topics within range, e.g. a..m, determined by params
	def get_range
		Rails.logger.info("HOST ------> #{request.host}")
		respond({ topics: AToZEntry.select(:topic, :id).where(topic: params[:start]..params[:end]) })
	end

	def cdc_search
		respond({ topics: AToZEntry.select(:topic, :id).contains(params[:search].upcase) })
	end

	def get_topic
		if AToZEntry.exists?(id: params[:id])
			respond({ status: 0, topic: AToZEntry.find(params[:id]) })
		else
			respond({ status: 1, error: "Topic not found" })
		end
	end


end
