

task ww_destroy_promos: :environment do 
	WwPromotion.destroy_all
end