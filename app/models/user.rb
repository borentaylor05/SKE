class User < ActiveRecord::Base
	belongs_to :client
	has_many :contents
	has_many :resolved_issues, class_name: "Issue", foreign_key: 'resolved_by'
	has_many :created_issues, class_name: "Issue", foreign_key: 'created_by'
	has_and_belongs_to_many :specialties
	# many to many b/t user and msg to track read messages
	has_many :message_trackers
	has_many :messages, through: :message_trackers
	accepts_nested_attributes_for :message_trackers
end
