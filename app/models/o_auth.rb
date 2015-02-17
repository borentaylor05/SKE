class OAuth < ActiveRecord::Base

	validates :token, presence: true
	validates :instance_url, presence: true
	validates :user_id, presence: true

end
