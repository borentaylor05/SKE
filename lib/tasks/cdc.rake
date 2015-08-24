require 'CDC'

task cdc_import_gamification: :environment do 
	cdc = CDC.new('dev')
	cdc.import_gamification("cdc_inbound_stack_rank.csv")
end

task parse_apg: :environment do 
	cdc = CDC.new('dev')
	cdc.parse_apg("B1001: NURSE Corps LRP (NCLRP) FY 2015 APG", "cdc.html")
end

task parse_s2_apg: :environment do 
	cdc = CDC.new('social')
	cdc.parse_apg("B1005: NHSC (S2S) APG FY 2016", "hrsa_apg_nhsc_s2.html")
end

task clean_apg: :environment do 
	CdcApgSection.destroy_all
	CdcApgSubheader.destroy_all
	CdcApgParagraph.destroy_all
	CdcApgNote.destroy_all
end