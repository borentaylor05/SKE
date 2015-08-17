class User < ActiveRecord::Base
	require 'Jive'
	require 'Jive2'
	require 'Util'

	scope :contains, -> (name) { where("lower(employee_id) like ? or lower(name) like ? or CAST(jive_id AS TEXT) like ?", "%#{name.downcase}%", "%#{name.downcase}%", "%#{name.downcase}%")}

	belongs_to :client
	validates :jive_id, presence: true
	validates :employee_id, presence: true
	validates :employee_id, uniqueness: true
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
		jive = Jive2.new('dev')
		CSV.foreach(file.path, headers: true) do |row|
			user = Util.parse_csv_user(row)
			# create_user params -> user: user hash, to_db: boolean (do you want user saved to local db)
		 	if jive.create_user(user, true) 
		 		created.push(user[:oracle_id])
		 	else
		 		errors.push(user[:oracle_id])
		 	end
		 	if user[:team_lead_oracle]
		 		u = User.find_by(employee_id: user[:oracle_id])
		 		tl = User.find_by(employee_id: user[:team_lead_oracle])
		 		if tl and u
		 			u.update_attributes(team_lead: tl) 
		 			tl_count += 1
		 		else
		 			tl_error.push(user[:team_lead_oracle])
		 		end
		 	end
		end
		return { created_count: created.count, error_count: errors.count, created: created, errors: errors, tls_added: tl_count, tl_error: tl_error }
	end

end
