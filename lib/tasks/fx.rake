require 'Util'

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
			redelivery: red[:redelivery],
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