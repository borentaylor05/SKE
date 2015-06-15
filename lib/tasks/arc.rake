require 'RedCross'

task bo: :environment do 
	arc = RedCross.new('dev')
	arc.bo_dates
end