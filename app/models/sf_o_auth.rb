class SfOAuth < ActiveRecord::Base

	validates :token, presence: true
	validates :instance_url, presence: true
	validates :user_id, presence: true
	belongs_to :user

	default_scope { order('created_at DESC') }

end
