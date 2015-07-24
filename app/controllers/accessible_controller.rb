class AccessibleController < ApplicationController
	require 'Jive'
	require 'Jive2'
	require 'Auth'
	require 'Bunchball'
	require 'CDC'
	require 'FX'
	require 'RedCross'

	before_action :authenticate_admin!
	before_filter :is_admin?, only: :new_admin
	before_filter :is_fairfax?, only: [:get_pubs, :get_deadlines_by_pub, :get_suburbs_by_condition, :fx_save_deadline, :upload_fx_classifications, :fx_edit_suburbs, :fx_edit_deadlines]
	before_filter :is_cdc?, only: [:a_to_z_entry, :get_topic, :get_range, :cdc_search, :az_save_changes, :edit_a_to_z, :upload_a_to_z, :upload_address_book]
	
	#VIEWS

	def cdc_home
	end

	def admins_home
		redirect_to "/"
	end

	def maintainers 
		@resolved = params['resolved'] == 'true' ? 'resolved' : 'unresolved'
	end

	def game_data_upload
		@client = params[:client].upcase
	end

	def gamification
	end

	def temp_util_upload		
	end

	def fx_upload_mag_pricing
	end

	def fx_upload_mag_pricing_process
		fx = FX.new('dev')
		results = fx.upload_mag_pricing(params[:file])
		respond({ results: results })
	end

	def temp_util_upload_process
		arc = RedCross.new('dev')
		created = arc.upload_check_tracker(params[:file])
		respond({ created: created[:good], errors: created[:errors] })
	end

	def gamification_upload		
	end

	def gamification_upload_process
		info = nil
		case params[:client]
		when 'cdc', 'fairfax'
			User.where(client: Client.find_by(name: params[:client])).each do |u|
				u.update_attributes(rank: nil, tier: nil, comp_score: nil)
			end
		else 
			info = "Client #{params[:client]} not found."
		end
		errors = Util.import_simple_gamification(params[:file])
		if errors.count == 0
			respond({ status: 0, message: "Success!", info: info })
		else
			respond({ status: 1, errors: errors, info: info })
		end
	end

	def prioritize_missions
		@client = params[:client].titleize
		if request.method == "POST"
			m = Mission.find(params[:mission][:id])
			m.update_attributes(mission_params)
			if m
				respond({ status: 0, mission: m })
			else
				respond({ status: 1, error: "Error saving mission." })
			end
		end
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

	def fx_upload_redelivery		
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

	def new_admin
	end

	def bulk_upload_users
	end

	#PROCESSES

	def bulk_upload_users_process
		results = User.import(params[:file])
		respond({ status: 0, results: results })		
	end

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

	def process_fx_redelivery_upload
		Redelivery.import(params[:file])
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

	def new_a_to_z
		if params[:scope]
			params[:scope] = params[:scope].upcase
		end
		if params[:topic]
			params[:topic] = params[:topic].upcase
		end
		az = AToZEntry.new(
			aka: params[:aka],
			owner: params[:owner],
			cdc_link: params[:cdc_link],
			spanish: params[:spanish],
			pr: params[:pr],
			topic: params[:topic],
			program_flow: params[:program_flow],
			notes: params[:notes],
			scope: params[:scope].upcase
		)
		if az.valid?
			az.save
			respond({ status: 0, az: az })
		else
			respond({ status: 1, error: az.errors.full_messages })
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
					request_type: params[:type]
				)
				if params[:expire_date]
					ar.expire_date = params[:expire_date].to_datetime
				end
				if params[:pub_date]
					ar.pub_date = params[:pub_date].to_datetime
				end
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
		resolved = false
		if params.has_key?("resolved") and params[:resolved] == "true"
			resolved = true
		end
		Rails.logger.info("RESOLVED = #{resolved} -> #{params[:resolved]}")
		Maintainer.where(resolved: resolved).limit(50).each do |m|
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
		jive = Jive2.new('social')
		hash = params[:user]
		oracle_id = hash[:employee_id]
		hash[:email] = "#{hash[:employee_id]}@nomail.com"
		hash[:password] = ENV['FP_PASSWORD']
		hash[:client] = Client.find_by(id: params[:user][:client_id]).name
		person = hash
		hash = Jive.new_jive_person(hash)
		resp = jive.create("/people", hash)
		Rails.logger.info(resp)
		if resp["error"] and resp["error"]["status"] == 409 and params.has_key?("update") and params[:update]
			json = jive.grab("/people/username/#{oracle_id}")
			params[:job_title] = params[:title]
			if jive.update_user_everywhere(json, params[:user])
				respond({ status: 0, message: "User updated successfully!" })
			else
				respond({ status: 1, error: "Error updating user." })
			end
		elsif (resp["error"] and resp["error"]["status"] == 409)
			respond({ status: 1, error: "exists" })
		elsif !resp["id"]
			respond({ status: 1, error: "Error creating user: #{resp} " })	
		else
			person[:jive_id] = resp["id"]
			u = User.new(
					first_name: person[:first_name], 
					last_name: person[:last_name],
					lob: person[:lob],
					title: person[:title],
					client_id: person[:client_id],
					employee_id: person[:employee_id],
					location: person[:location],
					jive_id: person[:jive_id],
					name: "#{person[:first_name]} #{person[:last_name]}"
				)
			if u.valid?
				u.save
				missionCount = u.assign_missions
				respond({ status: 0, user: u, missionCount: missionCount })
			else
				respond({ status: 1, error: u.errors.full_messages })
			end
		end
	end

	def get_mission
		
		if params.has_key?("name")
			m = Mission.find_by(bunchball_name: params[:name])
			if !m
				bb = Bunchball.new('3170083')
				resp = bb.get_mission(params[:name])
				respond({ status: 0, mission: resp })
			else
				respond({ status: 1, error: "Mission with that name has already been created." })
			end
		else
			respond({ status: 1, error: "Request needs name parameter" })
		end
	end

	def get_clients
		respond({ status: 0, clients: Client.select(:id, :name) })	
	end

	# /clients/:client/lobs-titles
	def get_lobs_titles_for_client
		if numeric?(params[:client])
			client = Client.find_by(id: params[:client])
		else
			client = Client.find_by(name: params[:client].downcase)
		end
		if client
			lobs = get_client_lobs(client.id)
			titles = get_client_titles(client.id)
			if lobs.count > 0
				respond({ status: 0, lobs: lobs, titles: titles })
			else
				respond({ status: 1, error: "No LOBS found.  Need to upload users." })
			end
		else
			respond({ status: 1, error: "Client not found." })
		end
	end

	def create_mission
		if params.has_key?("mission") and params.has_key?("bb")
			hash = make_mission(params[:mission], params[:bb])
			client = Client.find_by(name: params[:mission][:client].downcase)
			if hash[:game].valid?
				if hash[:mission].valid?
					hash[:game].save
					hash[:mission].game = hash[:game]
					hash[:mission].save
					if params[:mission][:all_lobs]
						Rails.logger.info("HEEEEERE <----------- All LOBs Checked")
						users = User.where(client: client)
					else
						Rails.logger.info("HEEEEERE <----------- NOOOO")
						users = User.where(client: client, lob: params[:mission][:lob].strip)
					end
					count = hash[:mission].assign_to_users(users)
					if users.count == count
						respond({ status: 0, assigned_to: users.count })
					else
						respond({ status: 1, error: "Something went wrong when assigning missions :( " })
					end
				else
					respond({ status: 1, error: hash[:mission].errors.full_messages })
				end
			else
				respond({ status: 1, error: hash[:game].errors.full_messages })
			end
		else
			respond({ status: 1, error: "You must have 'mission' and 'bb' params." })
		end
	end

	def get_missions
		if params.has_key?("client")
			client = Client.find_by(name: params[:client])
			if client 
				if params.has_key?("month")
					respond({ status: 0, missions: Mission.where(month: params[:month].titlecase, client_id: client.id) })
				else
					respond({ status: 0, missions: Mission.where(client_id: client.id) })
				end
			else
				respond({ status: 1, error: "Client #{params[:client].titleize} not found." })
			end
		else
			respond({ status: 1, error: "request needs a client" })
		end
	end

	def create_admin
		a = Admin.create(admin_params) 
		if a.valid?
			respond({ status: 0, message: "Admin created!" })
		else
			respond({ error: "#{a.errors.full_messages}", status: 1 })
		end
	end

	# ----- End Angular Request routes ------

	#UTILITY

	private

		def make_mission(mission, bb)
			client = Client.find_by(name: mission[:client].downcase)
			if mission[:all_lobs]
				mission[:lob] = 'all'				
			else
				mission[:lob] = mission[:lob].strip
			end
			m = Mission.new(
				bunchball_name: bb[:name],
				badge_url: bb[:fullUrl] ? bb[:fullUrl] : bb[:thumbUrl],
				description: bb[:description],
				folder: bb[:folderName],
				points: bb[:pointAward],
				month: mission[:month],
				lob: mission[:lob],
				client: client
			)
			case mission[:game_type]
			when 'Jive'
				game = JiveMission.new
			when 'Empower'
				game = EmpowerMission.new(
					metric_name: mission[:metric_name],
					target: mission[:target],
					units: mission[:units]
				)
			end
			return { mission: m, game: game }
		end

		def user_params
			params.require(:user).permit(:first_name, :last_name, :employee_id, :client_id, :title, :lob, :jive_id)
		end

		def entry_params
			params.require(:a_to_z_entry).permit(:owner, :aka, :scope, :notes, :program_flow, :cdc_link)
		end

		def deadline_params
			params.require(:deadline).permit(:publication, :nz_time, :mla_time, :run_day)
		end

		def admin_params
			params.require(:admin).permit(:email, :password, :client_id)
		end

		def maintainer_update_params
			params.require(:maintainer).permit(:pcf, :resolved, :training_impact, :response, :decision)
		end

		def mission_params
			params.require(:mission).permit(:badge_url, :bunchball_name, :id, :game_type, :game_id, :lob, :month, :folder, :description, :client_id, :created_at, :updated_at, :points, :priority)
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

		def get_client_lobs(client_id)
			return User.where(client_id: client_id).where.not("users.lob" => nil).uniq.pluck(:lob).sort_by(&:to_s)
		end

		def get_client_titles(client_id)
			return User.where(client_id: client_id).uniq.pluck(:title).sort_by(&:to_s)
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

		def is_admin?
			if admin_signed_in? and current_admin.administrator
				return true
			else
				redirect_to go_home
			end
		end

		def is_fairfax?
			if admin_signed_in?
				if current_admin.client.name == 'all' or current_admin.client.name == 'fairfax'
					return true
				else
					redirect_to "/"
				end
			else
				redirect_to "/"
			end
		end

		def is_cdc?
			if admin_signed_in?
				if current_admin.client.name == 'all' or current_admin.client.name == 'cdc'
					return true
				else
					redirect_to "/"
				end
			else
				redirect_to "/"
			end
		end

		def go_home
			case current_admin.client.name
			when 'all'
				redirect_to '/'	
			when 'cdc'

			else
				redirect_to '/'	
			end
		end

end
