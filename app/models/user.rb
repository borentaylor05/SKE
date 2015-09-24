class User < ActiveRecord::Base
	require 'Jive'
	require 'Jive2'
	require 'Util'
	require 'Bunchball'

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

	@@jive_template = {
	    emails: [ {
	      	value: "",
	      	type: "work",
	      	primary: true,
	      	jive_label: "Email"
	    } ],
	    jive: {
	      	password: "",
	      	username: "",
	      	profile: nil
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

	def self.jive_check_all
		User.where(jive_id: 0).each do |u|
			u.jive_create
		end
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
		User.jive_check_all
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
		client = Client.find_by(name: user[:client].downcase) || Client.find_by(name: Util.check_client_map(user[:client].downcase))
		User.new(
				employee_id: user[:employee_id].strip,
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

		client = Client.find_by(name: user[:client].downcase) || Client.find_by(name: Util.check_client_map(user[:client].downcase))
		if client 
			self.update_attributes(
				employee_id: user[:employee_id].strip,
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
		jive = Jive2.new('social')
		template = self.new_jive_person_hash
		puts template
		resp = jive.grab("/people/username/#{self.employee_id.strip}")
		if resp and resp["id"]
			update_response = jive.update("/people/#{self.jive_id}", template)
			if update_response["id"]
				self.update_attributes(jive_id: update_response["id"])
				self.set_bunchball_user_preference
				return true
			else
				Rails.logger.error "USER CREATE ERROR (Jive line 203): Employee -> #{self.employee_id} -- Error -> #{update_response}"
				return false
			end	
		elsif resp and (resp["error"] and [409,403].include?(resp["error"]["status"]))											
			juser = jive.grab("/people/username/#{self.employee_id.strip}")
			if juser and juser["id"]
				template[:jive][:enabled] = true
				jive.update("/people/#{juser["id"].strip}", template)
			else
				Rails.logger.error "USER CREATE ERROR (Jive line 212): Employee -> '#{self.employee_id}' -- Error -> #{juser} -- Original response: #{resp}"
				return false
			end
		elsif resp
			create_response = jive.create("/people", template)
			if create_response["id"]
				self.update_attributes(jive_id: create_response["id"])
				self.set_bunchball_user_preference
				return true
			else
				Rails.logger.error "USER CREATE ERROR (Jive): Employee -> #{self.employee_id} -- Error -> #{create_response}"
				return false
			end
		else
			return false
		end
	end

	def jive_update
		jive = Rails.env.production? ? Jive2.new('social') : Jive2.new('dev')
		user = jive.grab("/people/#{self.jive_id}")
		puts user
		if user and user["id"]
			user["emails"][0]["value"] = "#{self.employee_id}@nomail.com"
			user["jive"]["password"] = "Welcome1"
			user["jive"]["username"] = self.employee_id
			user["name"]["givenName"] = self.first_name
			user["name"]["familyName"] = self.last_name
			puts jive.update("/people/#{self.jive_id}", user)
		else
			puts "User #{self.jive_id} not found."
		end
	end

	def jive_delete 
		jive = Rails.env.production? ? Jive2.new('social') : Jive2.new('dev')
		if self.jive_id
			jive.remove("/people/#{self.jive_id.strip}")
		else
			resp = jive.grab("/people/username/#{self.employee_id.strip}")
			jive.remove("/people/#{resp["id"].strip}")
		end
	end

	def set_bunchball_user_preference
		if self.jive_id and self.jive_id > 0
			begin
				bb = Bunchball.new(self.jive_id)
				bb.set_preference({ name: "client", value: self.client.name })
			rescue NoMethodError
				Rails.logger.error "BB Error for #{self.inspect} - probably missing a client."
			end
		end
	end

	def new_jive_person_hash
        return {
            emails: [ {
                value: "#{self.employee_id}@nomail.com",
                type: "work",
                primary: true,
                jive_label: "Email"
            } ],
            jive: {
                password: ENV['FP_PASSWORD'],
                username: self.employee_id,
                profile: [
                  {
                    jive_label: "Title",
                    value: self.title
                  },
                  {
                    jive_label: "Client",
                    value: self.client.name.titleize
                  },
                  {
                    jive_label: "TeleTech Location",
                    value: self.location
                  },
                  {
                    jive_label: "LOB",
                    value: self.lob
                  },
                  {
                    jive_label: "Oracle ID",
                    value: self.employee_id
                  }
                ]
                 
            },
            name: {
                familyName: self.last_name,
                givenName: self.first_name
            }
        }
    end

end
