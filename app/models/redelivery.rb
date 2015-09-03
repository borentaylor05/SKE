class Redelivery < ActiveRecord::Base

	require 'FX'

	belongs_to :fx_publication

	def self.search(term)
		self.where("upper(town) like ? or upper(round_id) like ?", "%#{term.upcase}%", "%#{term.upcase}%")
	end

	def self.import(file)
		Redelivery.destroy_all
		fx = FX.new('social')
		fx.upload_redelivery(file)
	end

	def apify
		hash = self.attributes
		hash[:publication] = self.fx_publication.name
		return hash
	end

end
