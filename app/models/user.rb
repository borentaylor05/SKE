class User < ActiveRecord::Base
	require 'Jive'
	require 'Jive2'
	require 'Util'

	scope :contains, -> (name) { where("lower(employee_id) like ? or lower(name) like ? or CAST(jive_id AS TEXT) like ?", "%#{name.downcase}%", "%#{name.downcase}%", "%#{name.downcase}%")}
	
#	validates :jive_id, presence: true
	validates :employee_id, presence: true
	validates :client_id, presence: true
	validates :employee_id, uniqueness: true


	belongs_to :client
	has_many :contents
	has_many :resolved_issues, class_name: "Issue", foreign_key: 'resolved_by'
	has_many :created_issues, class_name: "Issue", foreign_key: 'created_by'
	has_and_belongs_to_many :specialties
	# many to many b/t user and msg to track read messages
	has_many :message_trackers
	has_many :messages, through: :message_trackers
	accepts_nested_attributes_for :message_trackers

	has_many :sf_o_auths
	has_many :user_missions
	has_many :missions, through: :user_missions

	has_one :team_lead, class: User
	belongs_to :team_lead, class: User, foreign_key: :team_lead_id

	@@jive = Rails.env.production? ? Jive2.new('social') : Jive2.new('dev')
	@@jive_template = {
	    emails: [ {
	      	value: "",
	      	type: "work",
	      	primary: true,
	      	jive_label: "Email"
	    } ],
	    jive: {
	      	password: "",
	      	username: ""
	    },
	    name: {
	      	familyName: "",
	      	givenName: ""
	    }
	}


	def leaderboard
		return User.where(client: self.client, lob: self.lob).where("rank > 0").limit(20).order("rank ASC")
	end

	def top_three_missions
		missions = [];
		Mission.joins(:user_missions).where("user_missions.times_completed" => 0, "user_missions.user_id" => self.id).uniq.limit(3).order("priority ASC").each do |m|
			ma = m.attributes 
			ma[:game] = m.game
			missions.push(ma)
		end
		return missions
	end

	def assign_missions
		c = 0
		Mission.where(client_id: self.client_id, lob: [self.lob, 'all']).each do |m|
			um = UserMission.new(
				mission: m,
				user: self,
				times_completed: 0,
				progress: 0,
				notify_complete: false
			)
			if um.valid? 
				um.save
				c += 1
			end
		end
		return c
	end

	def self.import(file)
		created = []
		errors = []
		tl_count = 0
		tl_error = []		
		CSV.foreach(file.path, headers: true) do |row|
			if row[0]
				user = Util.parse_csv_user(row)
				user[:team_lead_oracle] = row[8]
				u = User.find_by(employee_id: user[:employee_id])
				if u 
					if u.update(user)
						if u.jive_create
					 		created.push u.employee_id
					 	else
					 		errors.push "Jive Error (check logs): #{u.employee_id}"
					 	end
					else
						Rails.logger.error "USER CREATE ERROR: Bad client: #{user[:client]}"
						errors.push "USER CREATE ERROR: Bad client: #{user[:client]} -- #{user[:employee_id]}"
					end
				else
					u = User.make_new(user)
					if u and u.valid?
						u.save 
					 	if u.jive_create
					 		created.push u.employee_id
					 	else
					 		errors.push "Jive Error (check logs): #{u.employee_id}"
					 	end
					else
						Rails.logger.error "USER CREATE ERROR: #{u.errors.full_messages} -- Client: #{user[:client]} - User: #{user[:employee_id]}"
						errors.push "USER CREATE ERROR: #{u.errors.full_messages} -- Client: #{user[:client]} - User: #{user[:employee_id]}"
					end
				end	
				if user[:team_lead_oracle]
					if u.add_tl(user[:team_lead_oracle])
						tl_count += 1
					else
						tl_error.push(user[:team_lead_oracle])
					end
				end
			end
		end
		return { created_count: created.count, error_count: errors.count, created: created, errors: errors, tls_added: tl_count, tl_error: tl_error }
	end

	def add_tl(tl_oracle)
		if tl_oracle
	 		u = User.find_by(employee_id: self.employee_id)
	 		tl = User.find_by(employee_id: tl_oracle)
	 		if tl and u
	 			u.update_attributes(team_lead: tl) 
	 			return true
	 		else
	 			return false
	 		end
	 	end
	end

	def self.make_new(user)
		puts user
		client = Client.find_by(name: user[:client].downcase) || Util.check_client_map(user[:client].downcase)
		User.new(
				employee_id: user[:employee_id],
				client: client,
				title: user[:title],
				location: user[:location],
				lob: user[:lob],
				first_name: user[:first_name],
				last_name: user[:last_name],
				name: "#{user[:first_name]} #{user[:last_name]}"
			)
	end

	def update(user)
		client = Client.find_by(name: user[:client].downcase) || Util.check_client_map(user[:client].downcase)
		if client 
			self.update_attributes(
				employee_id: user[:employee_id],
				client: client,
				title: user[:title],
				location: user[:location],
				lob: user[:lob],
				first_name: user[:first_name],
				last_name: user[:last_name],
				name: "#{user[:first_name]} #{user[:last_name]}"
			)
		else						
			return false
		end
	end

	def jive_create
		template = @@jive_template
		template[:emails][0][:value] = "#{self.employee_id}@nomail.com"
		template[:jive][:password] = "Welcome1"
		template[:jive][:username] = self.employee_id
		template[:name][:givenName] = self.first_name
		template[:name][:familyName] = self.last_name
		resp = @@jive.grab("/people/username/#{self.employee_id}")
		puts "JIVERESPONSE"
		if resp and resp["id"]
			update_response = @@jive.update("/people", template)
			if update_response["id"]
				self.update_attributes(jive_id: update_response["id"])
				return true
			else
				Rails.logger.error "USER CREATE ERROR (Jive): Employee -> #{self.employee_id} -- Error -> #{update_response}"
				return false
			end			
		elsif resp
			create_response = @@jive.create("/people", template)
			if create_response["id"]
				self.update_attributes(jive_id: create_response["id"])
				return true
			else
				Rails.logger.error "USER CREATE ERROR (Jive): Employee -> #{self.employee_id} -- Error -> #{update_response}"
				return false
			end
		else
			return false
		end
	end

	def jive_delete 
		if self.jive_id
			@@jive.remove("/people/#{self.jive_id}")
		else
			resp = @@jive.grab("/people/username/#{self.employee_id}")
			@@jive.remove("/people/#{resp["id"]}")
		end
	end

end
