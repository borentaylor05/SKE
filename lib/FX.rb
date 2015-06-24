require 'Jive2'

class FX
	include ActionView::Helpers::NumberHelper

	def initialize(instance)
		@jive = Jive2.new(instance)
	end

	def upload_code_rates(file,name)
		CSV.foreach(file, headers: true) do |row|
			pub = FxPublication.find_by(name: name)
			if row[0] and pub
			 	fxcr = FxCodeRate.new(
			 		fx_publication: pub,
			 		schedule: row[0].strip,
			 		month_code: row[1].strip,
			 		month_rate: dollar_to_decimal(row[2]),
			 		year_code: row[3].strip,
			 		year_rate: dollar_to_decimal(row[4]),
			 		other: row[5] ||= nil,
			 		three_day: row[6].strip == "1" ? true : false
			 	)
			 	if fxcr.valid?
			 		fxcr.save
			 		puts "Good #{name}"
			 	else
			 		puts fxcr.errors.full_messages
			 	end
			else
				puts "Row empty or pub not found - #{name}"
			end
		end
	end

	def upload_redelivery(file)
		Redelivery.destroy_all
		CSV.foreach(file.path, headers: true) do |row|
			if row[0]
				pub = FxPublication.find_by(name: row[0].strip)
				if pfb
					red = Redelivery.new(
						fx_publication: pub,
						round_id: row[1].upcase,
						town: row[2].upcase,
						cutoff_mf: row[3],
						cutoff_sat: row[4],
						cutoff_sun: row[5] 
					)
					if red.valid?
						red.save
					#	Rails.logger.info "Created #{row[1]} - #{row[2]}"
					else
						Rails.logger.info "Error - row[1] - #{red.errors.full_messages}"
					end
				else
					Rails.logger.info "Error: Pub not found #{row[0]} = #{row[2]}"
				end
			end
		end
	end

	private 

		def dollar_to_decimal(num)
			return number_with_precision(num.gsub!('$', ''), precision: 2)
		end

end