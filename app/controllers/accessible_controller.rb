class AccessibleController < ApplicationController
	require 'Jive'
	require 'Auth'

	before_action :authenticate_admin!
	
	#VIEWS

	def maintainers
	end

	def new_user
	end

	def fx_edit_suburbs
	end

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

	def temp_upload_local
	end

	def upload_deadlines
	end

	def edit_a_to_z
	end

	def fx_edit_deadlines
	end

	#PROCESSES

	def temp_upload_process
		results = TempUser.import(params[:file])
		respond({ status: 0, results: results })
	end

	def temp_upload_process_db_only
		results = TempUser.import_db_only(params[:file])
		respond({ status: 0, results: results })
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

	# Deadlines (Fairfax)

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

	# Maintainers

	def new_article_request
		if(request.method == "OPTIONS")
			respond({status: 1})
		elsif request.method == "POST"
			Rails.logger.info("PARAMS ----> #{params}")
			user = current_admin
			if user.nil?
				respond({ status: 1, error: "User not found", type: "NoUser" })
			elsif user.client.nil? && params[:client].blank?
				respond({ status: 1, error: "No client for user", type: "NoClient" })			
			else
				client = user.client
				ar = ArticleRequest.new(
					title: params[:title],
					summary: params[:summary],
					lob: params[:lob],
					priority: params[:priority].to_i,
					request_type: params[:type],
					expire_date: params[:expire_date].to_datetime,
					pub_date: params[:pub_date].to_datetime
				)
				ar = get_attachments(params,ar)
				if ar.valid?
					ar.save
					m = Maintainer.new(client: current_admin.client, admin: current_admin, ticket: ar, resolved: false, lob: params[:lob])
					if m.valid?
						m.save
						respond({ status: 0, message: "Article Request Saved!" })
					else
						respond({ status: 1, error: "#{m.errors.full_messages}" })
					end
				else
					respond({ status: 1, error: "#{ar.errors.full_messages}" })
				end
			end
		end
	end

	def get_maintainers
		ms = []
		Maintainer.where(resolved: false).limit(50).each do |m|
			if m.do_delete == true
				m.destroy
				m.ticket.destroy
			else
				ms.push(m.makeRelevant)
			end
		end
		respond({ m: ms })
	end

	def toggle_resolved
		m = Maintainer.find_by(id: params[:id])
		if m
			if m.resolved
				m.update_attributes(resolved: false)
			else
				m.update_attributes(resolved: true)
			end
			respond({ status: 0, message: "Toggled" })
		else
			respond({ status: 1, error: "Maintainer not found" })
		end
	end

	def update_maintainer
		m = Maintainer.find_by(id: params[:maintainer][:id])
		prevDecision = m.decision
		prevResponse = m.response
		if m.update_attributes(maintainer_update_params)
			respond({ status: 0, message: "Maintainer Updated" })
			# send message to requester containing new decision and response
			message = ""
			if m.response != prevResponse
				message = "Response: #{m.response} \n\n"
			end	
			if m.decision != prevDecision
				message =  "#{message}Decision: #{m.decision}</br>"
			end
			if message.length > 0
				message = determine_type(m, message)
				my_admin_user = User.find_by(jive_id: 99999999)
				logger.info("ADMIN ------------> #{my_admin_user}")
				msg = Message.new(
					user: my_admin_user, # sender is system admin user (jive_id = 99999999)
					text: message,
					client: my_admin_user.client
				)
				if msg.valid?
					Rails.logger.info("MESSAGE -----> #{msg.user.jive_id}")
					msg.save
					msg.send_message([m.user.jive_id])
				else
					Rails.logger.info("ERROR -----> #{m.errors.full_messages}")
				end
			end
		else
			respond({ status: 1, error: "Unable to save" })
		end
	end

	def get_suburbs_by_condition
		all = []
		case params[:condition]
		when 'range'
		when 'with-period'
		when "length"
			subs = Suburb.find_by_sql("select suburbs.* from suburbs where LENGTH(name) > #{params[:length]}")
			subs.each do |sub|
				s = sub.attributes
				s[:publications] = sub.fx_publications
				all.push(s) 
			end
		end
		respond({ status: 0, matches: all }) 
	end

	def save_suburbs
		
	end

	def create_user
		hash = params[:user]
		hash[:email] = "#{hash[:employee_id]}@nomail.com"
		hash[:password] = ENV['FP_PASSWORD']
		person = hash
		hash = Jive.new_person(hash)
		resp = Jive.create("#{Jive.dev_url}/people", hash, Auth.dev)
		if(resp["error"])
			respond({ status: 1, error: resp["error"] })
		else
			person[:jive_id] = resp["id"]
			u = User.new(
					first_name: person[:first_name], 
					last_name: person[:last_name],
					lob: person[:lob],
					title: person[:job_title],
					client_id: person[:client_id],
					employee_id: person[:employee_id],
					jive_id: person[:jive_id],
					name: "#{person[:first_name]} #{person[:last_name]}"
				)
			if u.valid?
				u.save
				respond({ status: 0, user: u })
			else
				respond({ status: 1, error: u.errors.full_messages })
			end
		end
	end

	# ----- End Angular Request routes ------

	#UTILITY

	private

		def user_params
			params.require(:user).permit(:first_name, :last_name, :employee_id, :client_id, :title, :lob, :jive_id)
		end

		def entry_params
			params.require(:a_to_z_entry).permit(:owner, :aka, :scope, :notes, :program_flow, :cdc_link)
		end

		def deadline_params
			params.require(:deadline).permit(:publication, :nz_time, :mla_time, :run_day)
		end

		def maintainer_update_params
			params.require(:maintainer).permit(:pcf, :resolved, :training_impact, :response, :decision)
		end

		def determine_type(maintainer, message)
			case maintainer.ticket_type
			when "CommentIssue"
				message = "In response to comment #{maintainer.ticket.old_comment.old_content.link}#comment-#{maintainer.ticket.old_comment.api_id} \n\n #{message}"
			when "ArticleRequest"
				message = "In response to your article request titled: '#{maintainer.ticket.title}' \n\n #{message}"
			end
			return message
		end

		def get_attachments(params,ar)
			if params.has_key?("file_label")
				ar.file_label = params[:file_label]
			end
			if params.has_key?("file_label2")
				ar.file_label2 = params[:file_label2]
			end
			if params.has_key?("file_label3")
				ar.file_label3 = params[:file_label3]
			end
			if params.has_key?("file_url")
				ar.file_url = params[:file_url]
			end
			if params.has_key?("file_url2")
				ar.file_url2 = params[:file_url2]
			end
			if params.has_key?("file_url3")
				ar.file_url3 = params[:file_url3]
			end
			return ar
		end

end
