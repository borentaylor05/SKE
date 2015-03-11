class AccessibleController < ApplicationController
	
	before_action :authenticate_admin!
	
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

	# HTTP REQUESTS (Angular)
	# A to Z
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

	def get_deadlines_by_pub
		deadlines = []
		days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
		days.each do |day|
			hash = { day: day, deadlines: Deadline.day(day).contains(params[:pub]) }
			deadlines.push(hash)
		end
		respond({ status: 0, deadlines: deadlines })
	end

	def get_pubs
		pubs = []
		Deadline.uniq.pluck(:publication).each do |p|
			name = p.match('^[^\(]*').to_s.strip
			name = name.match('^[^\-]*').to_s.strip
			if name[0] == "*"
				name[0] = ''
			end
			if !pubs.include?(name)
				pubs.push(name)
			end
		end
		respond({ status: 0, pubs: pubs })
	end

	# ----- End Angular Request routes ------

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
