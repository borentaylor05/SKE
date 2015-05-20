require 'CDC'

task cdc_import_gamification: :environment do 
	cdc = CDC.new('dev')
	cdc.import_gamification("cdc_inbound_stack_rank.csv")
end