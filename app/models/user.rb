class User < ActiveRecord::Base
	belongs_to :client
	has_many :contents
	has_and_belongs_to_many :specialties
end
