class OldContent < ActiveRecord::Base
	validates :api_id, presence: true
	validates :comments, presence: true
	has_many :old_comments
end
