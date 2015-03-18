class FxPublication < ActiveRecord::Base
	validates :name, presence: true
	has_and_belongs_to_many :suburbs
	scope :contains, -> (search) { where("lower(name) like ?", "%#{search.downcase}%")}
end
