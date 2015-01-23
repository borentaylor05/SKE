class AccessibleController < ApplicationController
	skip_before_action :verify_authenticity_token
	#VIEWS

	def upload_address_book
	end

	def upload_a_to_z
	end

	def cdc_verification
		
	end

	def edit_a_to_z
		
	end

	#PROCESSES

	def process_address_book_upload
		AddressBookEntry.import(params[:file])
		respond({ status: 0, message: "Upload Successful" })
	end

	def process_a_to_z_upload
		AToZEntry.import(params[:file])
		respond({ status: 0, message: "Upload Successful" })
	end

	def az_save_changes
		if AToZEntry.exists?(id: params[:a_to_z_entry][:id])
			entry = AToZEntry.find(params[:a_to_z_entry][:id])
			entry = entry.update_attributes!(entry_params)
			respond({ status: 0, entry: entry })
		else
			respond({ status: 1, error: "Entry Not Found" })
		end
	end

	#UTILITY

	# gets all topics within range, e.g. a..m, determined by params
	def get_all_topics
		respond({ topics: AToZEntry.select(:topic, :id).where(topic: params[:start]..params[:end]) })
	end
	def get_topic
		if AToZEntry.exists?(id: params[:id])
			respond({ status: 0, topic: AToZEntry.find(params[:id]) })
		else
			respond({ status: 1, error: "Topic not found" })
		end
	end

	def verify
		if(params[:password] == "password")
			respond({ status: 0, token: generate_token(100) })
		else
			respond({ status: 1, error: "Wrong Password" })
		end
	end

	private

		def entry_params
			params.require(:a_to_z_entry).permit(:owner, :aka, :scope, :notes)
		end

end
