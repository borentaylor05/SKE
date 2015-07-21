class CdcApgSection < ActiveRecord::Base

	has_many :cdc_apg_subheaders

	def apify
		return { section: self, subheaders: self.apify_subheaders }
	end

	def apify_subheaders
		all = []
		self.cdc_apg_subheaders.each do |sub|			
			all.push(sub.apify)			
		end
		return all
	end

end
