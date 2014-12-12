class Client < ActiveRecord::Base
	has_many :users
	has_many :contents
	has_many :posts
	has_many :updates
	has_many :specialties
end
