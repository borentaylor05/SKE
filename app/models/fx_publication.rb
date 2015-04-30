class FxPublication < ActiveRecord::Base
	validates :name, presence: true
	has_many :redeliveries
	has_one :fx_mag_pricing
	has_and_belongs_to_many :suburbs
	has_and_belongs_to_many :cost_per_thousands
	default_scope { order('name ASC') }
	scope :contains, -> (search) { where("lower(name) like ?", "%#{search.downcase}%")}
end
