class AccessibleController < ApplicationController
	before_action :access_check
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers
	before_action :authenticate_admin!
#	before_action :verify, only: [:upload_deadlines, :upload_fx_classifications, :fx_request_article, :upload_address_book, :upload_a_to_z, :edit_a_to_z, :fx_edit_deadlines]
	#VIEWS

	def fx_request_article
		
	end

	def upload_address_book	
	end

	def upload_a_to_z
	end

	def upload_fx_classifications
	end

	def temp_upload
	end

	def upload_deadlines
	end

	def edit_a_to_z
	end

	def fx_edit_deadlines
		
	end

	#PROCESSES

	def temp_upload_process
		TempUser.import(params[:file])
		respond({ status: 0, message: "Upload Successful" })
	end

	def process_address_book_upload
		AddressBookEntry.import(params[:file])
		respond({ status: 0, message: "Upload Successful" })
	end

	def process_fx_classification_upload
		FxClassification.import(params[:file])
		respond({ status: 0, message: "Upload Successful" })
	end

	def process_a_to_z_upload
		AToZEntry.import(params[:file])
		respond({ status: 0, message: "Upload Successful" })
	end

	def process_deadlines
		Deadline.import(params[:file])
		respond({ status: 0, message: "Upload Successful" })
	end

	def az_save_changes
		if AToZEntry.exists?(id: params[:a_to_z_entry][:id])
			entry = AToZEntry.find(params[:a_to_z_entry][:id])
			if(params[:a_to_z_entry][:spanish])
				if entry.spanish
					entry.update_attributes!(spanish: false)
				else
					entry.update_attributes!(spanish: true)
				end
			end
			if(params[:a_to_z_entry][:pr])
				if entry.pr
					entry.update_attributes!(pr: false)
				else
					entry.update_attributes!(pr: true)
				end
			end
			entry = entry.update_attributes!(entry_params)
			respond({ status: 0, entry: entry })
		else
			respond({ status: 1, error: "Entry Not Found" })
		end
	end

	def fx_save_deadline
		if Deadline.exists?(id: params[:deadline][:id])
			dl = Deadline.find(params[:deadline][:id])
			dl.update_attributes!(deadline_params)
			respond({ status: 0, deadline: dl })
		else
			respond({ status: 1, error: "Deadline Not Found" })
		end

	end

	#UTILITY

	# Moved to a_to_z controller

	private

		def entry_params
			params.require(:a_to_z_entry).permit(:owner, :aka, :scope, :notes, :program_flow, :cdc_link)
		end

		def deadline_params
			params.require(:deadline).permit(:publication, :nz_time, :mla_time, :run_day)
		end


end
