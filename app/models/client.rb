class Client < ActiveRecord::Base
	has_many :users
	has_many :contents
	has_many :posts
	has_many :updates
	has_many :admins
	has_many :specialties
	has_many :content_requests
	has_many :message_trackers
	has_many :messages, through: :message_trackers
	has_many :missions
	has_many :cdc_apg_documents
end
