class FxPublication < ActiveRecord::Base
	validates :name, presence: true
	has_many :redeliveries
	has_many :fx_code_rates
	has_many :fx_mag_pricing
	has_one :fx_se_pricing
	has_and_belongs_to_many :suburbs
	has_and_belongs_to_many :cost_per_thousands
	default_scope { order('name ASC') }
	scope :contains, -> (search) { where("lower(name) like ?", "%#{search.downcase}%")}

	def apify
		self.suburbs.map do |burb|
			b = burb.attributes
			b[:paper] = self.name
		end
	end

end
