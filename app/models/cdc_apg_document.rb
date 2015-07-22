class CdcApgDocument < ActiveRecord::Base

	has_many :cdc_apg_sections
	belongs_to :client

	def subheaders
		topics = []
		self.cdc_apg_sections.each do |section|
			topics = topics + section.cdc_apg_subheaders
		end
		return topics
	end

end
