class CostPerThousand < ActiveRecord::Base
	validates :publications, presence: true
	validates :cost, presence: true
	has_and_belongs_to_many :fx_publications
end
