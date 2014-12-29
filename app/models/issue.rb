class Issue < ActiveRecord::Base
	belongs_to :resolver, class_name: "User", foreign_key: 'resolved_by'
	belongs_to :creator, class_name: "User", foreign_key: 'created_by'
	belongs_to :content
	has_one :post, as: :action
	validates :url, uniqueness: true
end
