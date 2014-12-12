class Specialty < ActiveRecord::Base
	belongs_to :client
	validates :name, presence: true
	has_and_belongs_to_many :users
	has_and_belongs_to_many :contents
end
