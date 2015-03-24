class FxPublication < ActiveRecord::Base
	validates :name, presence: true
	has_many :redeliveries
	has_and_belongs_to_many :suburbs
	has_and_belongs_to_many :cost_per_thousands
	scope :contains, -> (search) { where("lower(name) like ?", "%#{search.downcase}%")}
end
