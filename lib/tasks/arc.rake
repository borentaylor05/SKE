require 'RedCross'

task bo: :environment do 
	arc = RedCross.new('dev')
	arc.bo_dates
end

task add_expiration: :environment do 
	ArcBlackoutDate.all.each do |date|
		begin 
			expires = expires = date.date ? Date.strptime(date.date, '%m/%d/%Y') : nil
			expires_yellow = date.notes ? Date.strptime(date.notes, '%m/%d/%Y') : nil
			date.update_attributes(expires: expires, expires_yellow: expires_yellow)
		rescue ArgumentError, TypeError
			puts "Invalid Date: #{date.date} for #{date.id}"
		end
	end
end

task clean_bo_dates: :environment do
	ArcBlackoutTracker.destroy_all
	ArcBlackoutDate.destroy_all
	ArcCityState.destroy_all
end

task remove_old_blackout_dates: :environment do 
	ArcBlackoutDate.where("expires < now() - INTERVAL '1 Day'").each do |d| 
		d.arc_blackout_trackers.destroy_all
		d.destroy 
	end
end