class Redelivery < ActiveRecord::Base

	belongs_to :fx_publication

	def self.search(term)
		self.where("lower(town) like ? or lower(round_id) like ?", "%#{term.downcase}%", "%#{term.downcase}%")
	end

end
