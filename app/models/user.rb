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

end
