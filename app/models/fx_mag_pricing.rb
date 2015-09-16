class FxMagPricing < ActiveRecord::Base
	validates :fx_publication_id, presence: true
	belongs_to :fx_publication

	def self.import(file)
		FxMagPricing.destroy_all
		cur = ""
		errors = []
		created = 0
		CSV.foreach(file.path, headers: true) do |row|			
			if row[0]
				pub = FxPublication.find_by(name: row[0].strip)
				if pub 
					pricing = new_from_csv(row)
					if pricing.valid?
						pricing.save
						created += 1
					else
						errors.push "#{row[0]} - #{pub.errors.full_messages}"
					end
				else
					errors.push "Pub #{row[0]} not found"
				end
			end
		end
		return { errors: errors, created: created }
	end

	def new_from_csv(row)
		return FxMagPricing.new(
				pay_type: row[1],
				six_month: row[2],
				one_year: row[3],
				one_year_aus: row[4],
				one_year_row: row[5],
				two_years: row[6],
				three_years: row[7],
				bank: row[8],
				credit: row[9],
				fx_publication: pub
			)
	end

end
