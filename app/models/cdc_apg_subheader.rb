class CdcApgSubheader < ActiveRecord::Base

	belongs_to :cdc_apg_section

	has_many :cdc_apg_paragraphs
	has_many :cdc_apg_notes

	def apify
		return { title: self.title, paragraphs: self.cdc_apg_paragraphs, notes: self.cdc_apg_notes }
	end

end
