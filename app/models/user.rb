class User < ActiveRecord::Base
	
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
		Mission.where(client_id: self.client_id, lob: self.lob).each do |m|
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

end
