require 'CDC'

task cdc_import_gamification: :environment do 
	cdc = CDC.new('dev')
	cdc.import_gamification("cdc_inbound_stack_rank.csv")
end

task parse_apg: :environment do 
	cdc = CDC.new('dev')
	cdc.parse_apg
end

task clean_apg: :environment do 
	CdcApgSection.destroy_all
	CdcApgSubheader.destroy_all
	CdcApgParagraph.destroy_all
	CdcApgNote.destroy_all
end