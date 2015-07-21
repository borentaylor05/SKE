class AToZController < ApplicationController

	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers
	after_action :allow_iframe
	

	# gets all topics within range, e.g. a..m, determined by params
	def get_range
		if params.has_key?("start") and params.has_key?("end")
			if params["end"] == "Z"
				# had to do some hackish stuff to include Z
				first = AToZEntry.select(:topic, :id).where(topic: params[:start]..params[:end])
				prefix = 'Z'
				second = AToZEntry.select(:topic, :id).where("topic LIKE :prefix", prefix: "#{prefix}%")
				respond({ status: 0, topics: first+second })
			else
				respond({ status: 0, topics: AToZEntry.select(:topic, :id).where(topic: params[:start]..params[:end]) })
			end			
		else
			respond({ status: 1, error: "Must supply :start and :end parameter." })
		end	
	end

	def cdc_search
		if params.has_key?("search")
			respond({ status: 0, topics: AToZEntry.select(:topic, :id).contains(params[:search].upcase) })
		else
			respond({ status: 1, error: "Must supply :search parameter." })
		end
	end

	def get_topic
		a = AToZEntry.find_by(id: params[:id])
		if a
			respond({ status: 0, topic: a })
		else
			respond({ status: 1, error: "Topic not found" })
		end
	end


end
