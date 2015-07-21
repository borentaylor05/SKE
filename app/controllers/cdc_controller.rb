class CdcController < ApplicationController

	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers
	after_action :allow_iframe

	# HRSA FUNCTIONS

	def get_categories_and_topics
		if params.has_key?("topics") and params[:topics]
			respond({ status: 0, categories: CdcApgSection.all, topics: CdcApgSubheader.all })
		else
			respond({ status: 0, categories: CdcApgSection.all })
		end
	end

	def get_topic
		topic = CdcApgSubheader.find_by(id: params[:id])
		if topic
			respond({ status: 0, topic: topic.apify })
		else
			respond({ status: 1, message: "No topic #{params[:id]}" })
		end
	end

	def get_category
		topic = CdcApgSection.find_by(id: params[:id])
		if topic
			respond({ status: 0, topics: topic.cdc_apg_subheaders })
		else
			respond({ status: 1, message: "No topic #{params[:id]}" })
		end
	end

end
