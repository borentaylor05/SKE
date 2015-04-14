class Mission < ActiveRecord::Base

	validates :bunchball_name, presence: true
	validates :folder, presence: true
	validates :bunchball_name, uniqueness: true

	belongs_to :client
	belongs_to :game, touch: true, polymorphic: true
	has_many :user_missions
	has_many :users, through: :user_missions

	def assign_to_users(users)
		c = 0
		users.each do |u|
			um = UserMission.new(
				mission: self,
				user: u,
				times_completed: 0,
				progress: 0,
				notify_complete: false
			)
			if um.valid?
				c += 1
				um.save
			end
		end
		return c
	end
end
