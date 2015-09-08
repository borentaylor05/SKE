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

task remove_cities: :environment do 
	arc = RedCross.new("social")
	cities = "Arlington, Alexandria, Fairfax, Falls Church, Woodbridge, Manassas, Manassas Park, Haymarket, Occoquan, Independent Hill, Rixiew, Greenwich, Groveton, Quantico, Buckhall, Canova, Aden, Hickory Ridge, Dumfries, Brentsville, Buckland, Antioch, Bristow, Carharpin, Minnieville, Cornwell, Joplin, Thoroughfare, Kopp, Leesburg, Aldie, Ashburn, Lovettsville, Brambleton, Purcellville, Middleburg, South Riding, Round Hill, Waterford, Bluemont, Hamilton, Dulles, Hillsboro, Lucketts, Arcola, Broadlands, Stone Ridge, Sterling Park, Philoment, Oatlands, Paeonian Springs, Taylorstown, Loudoun Heights, Gilberts Corner, Unison, Waxpool, Lenah, Neersville, Lincoln, Sycolin, Wheatland, Clifton, Dranesville, Vienna, Fair Lakes, Occoquan, Herndon, Langley, Fairfax Station, Oak Hill, Greenbriar, Accotink, Culmore, Pohick Mason Neck, Colchester, Jermantown, Cooktown, Rutherford, Butts Corner, Odricks Corner, Comptons Corner, Arcturus, Five Forks, Hollindale, Blevinstown, Westhampton, Barkers Crossroads, Colchester, Cobbs Corner, Browns Mill, Shady Oak, Hayfield, Ft. Belvoir, Cape Charles, Exmore, Cherton, Cherrystone, Eastville, Nassaswadox, Belle Haven, Birdsnest, Accomac, Parksley, Tangler, Belle Haven, Keller, Onancock, Onley, Wachapreague, Bloxom, Hailwood, Chincotegue, Melfa, Painter, Saxis, Assawoman"
	state = State.find_by(abbreviation: "MD")
	cities = cities.split(",").map(&:strip)
	cities.each do |c|
		arc.remove_city(c,state)
	end
end