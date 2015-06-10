require 'Jive2'

class FX

	def initialize(instance)
		@jive = Jive2.new(instance)
	end

	def upload_redelivery(file)
		Redelivery.destroy_all
		CSV.foreach(file.path, headers: true) do |row|
			if row[0]
				pub = FxPublication.find_by(name: row[0].strip)
				if pub
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

end