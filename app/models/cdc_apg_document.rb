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

	def delete
		self.cdc_apg_sections.each do |section|
			section.cdc_apg_subheaders.each do |sub|
				sub.cdc_apg_paragraphs.destroy_all
				sub.cdc_apg_notes.destroy_all
				sub.destroy
			end
			section.destroy
		end
		self.destroy
	end

end
