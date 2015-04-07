class Mission < ActiveRecord::Base

	validates :bunchball_name, presence: true
	validates :folder, presence: true

	belongs_to :game, touch: true, polymorphic: true
	has_many :user_missions
	has_many :users, through: :user_missions
end
