class Suburb < ActiveRecord::Base
	scope :contains, -> (search) { where("lower(name) like ?", "%#{search.downcase}%")}
	has_and_belongs_to_many :fx_publications
end
