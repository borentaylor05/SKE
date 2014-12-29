class User < ActiveRecord::Base
	belongs_to :client
	has_many :contents
	has_many :resolved_issues, class_name: "Issue", foreign_key: 'resolved_by'
	has_many :created_issues, class_name: "Issue", foreign_key: 'created_by'
	has_and_belongs_to_many :specialties
end
