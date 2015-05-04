require 'Util'
require 'SFTP'

task import_redelivery: :environment do 
	CSV.foreach('nz_redelivery.csv', headers: true) do |row|
		pub = FxPublication.find_by(name: row[0].strip)
		if !pub 
			pub = FxPublication.create(name: row[0].strip)
		end
		red = Util.parse_redelivery_row(row)
		newRed = Redelivery.new(
			town: red[:town],
			round_id: red[:round_id],
			redelivery: red[:redelivery].downcase == "Yes".downcase ? true : false,
			cutoff_mf: red[:cutoff_mf],
			cutoff_sat: red[:cutoff_sat],
			cutoff_sun: red[:cutoff_sun]
		)
		if newRed.valid?
			newRed.save
			pub.redeliveries << newRed
		else
			puts newRed.errors.full_messages
		end
	end
end

task :make_fairfax_mlevel_csv => :environment do |t,args|
	CSV.open("tmp/fairfax_users_mlevel.csv", 'w') do |file|
		User.where(client: Client.find_by(name: "fairfax")).each do |user|
			file << [ user.first_name, user.last_name, "#{user.employee_id}@teletech.com", user.employee_id, user.title, user.client.name, "APAC", user.lob, eval(ENV["MLEVEL_PASSWORD_FOR_USER"]) ]
		end
		CSV.foreach('public/mlevel_test.csv', headers: true) do |row|
			user = Util.parse_csv_user(row)
			file << [ user[:first_name], user[:last_name], "#{user[:oracle_id]}@teletech.com", user[:oracle_id], user[:job_title], user[:client].downcase, "APAC", user[:lob], eval(ENV["MLEVEL_PASSWORD_FOR_ADMIN"]) ]
		end
	end
	sftp = SFTP.new('mlevel')
	sftp.send('tmp/fairfax_users_mlevel.csv')
end

task insert_mags: :environment do 
	CSV.foreach("mag_prices.csv", headers: true) do |row|
		pub = FxPublication.find_by(name: row[0].strip)
		if !pub 
			pub = FxPublication.create(name: row[0].strip, mag: true)
			p = FxMagPricing.create(
				six_month: row[1],
				one_year_renewal: row[2],
				one_year_new: row[3],
				two_year_new: row[4],
				two_year_renewal: row[5],
				one_year_supergold: row[6],
				three_year_new: row[7],
				three_year_renewal: row[8]
			)
			pub.fx_mag_pricing = p
		else
			puts "Exists #{row[0]}"
		end
	end
end

task insert_ses: :environment do 
	CSV.foreach("se.csv") do |row|
		if !row[0].strip.blank?
			parent = FxPublication.find_by(name: row[0].strip)
			puts parent.name
			if parent
				count = 0
				row.each do |se|
					if se and count > 0
						pub = FxPublication.create(name: se.strip, parent: parent.name, mag: true, se: true)
					end
					count += 1
				end
			else
				puts "ERROR: #{row[0]}"
			end
		end
	end	
end

task insert_has_se: :environment do 
	FxPublication.all.each do |p|
		if p.se 
			parent = FxPublication.find_by(name: p.parent)
			if parent
				parent.update_attributes(has_se: true)
			else
				puts "ERROR: #{p.name}"
			end
		end
	end
end



