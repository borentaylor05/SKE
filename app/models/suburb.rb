class Suburb < ActiveRecord::Base
	
	validates :name, presence: true
	
	scope :contains, -> (search) { where("lower(name) like ?", "%#{search.downcase}%")}
	default_scope { order('name ASC') }

	has_and_belongs_to_many :fx_publications

	def apify 
		b = self.attributes 
		b[:paper] = @paper
		return b
	end

	def paper=(value)
		@paper = value
	end

end
