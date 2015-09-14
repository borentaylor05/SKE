class HrsaController < ApplicationController
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers
	after_action :allow_iframe

	# HRSA FUNCTIONS
	# 
	# Misnamed models (they say CDC but should be HRSA)

	def apg_init
		doc = CdcApgDocument.find_by(id: params[:id])
		if doc
			respond({ status: 0, doc: doc, categories: doc.cdc_apg_sections, topics: doc.subheaders })
		else
			respond({ status: 1, error: "Doc #{params[:id]} not found." })
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
