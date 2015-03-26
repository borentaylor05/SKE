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
	puts sftp.send('tmp/fairfax_users_mlevel.csv')
end

task :fx_bash => :environment do
	`sftp -vv -oPort=10022 teletech@securefiletransfer.mlevel.com`
end
