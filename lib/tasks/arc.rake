require 'RedCross'

task bo: :environment do 
	arc = RedCross.new('dev')
	arc.bo_dates
end

task clean_bo_dates: :environment do
	ArcBlackoutTracker.destroy_all
	ArcBlackoutDate.destroy_all
	ArcCityState.destroy_all
end