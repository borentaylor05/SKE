class Content < ActiveRecord::Base
	belongs_to :client
	belongs_to :user
	validates_uniqueness_of :api_id
	validates_uniqueness_of :doc_id
	has_one :post, as: :action
	has_and_belongs_to_many :specialties
	has_many :issues
end
