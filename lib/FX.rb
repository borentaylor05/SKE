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

	def upload_mag_pricing(file)
		FxMagPricing.destroy_all
		cur = ""
		errors = []
		created = 0
		CSV.foreach(file.path, headers: true) do |row|			
			if row[0]
				pub = FxPublication.find_by(name: row[0].strip)
				if pub 
					pricing = FxMagPricing.new(
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

	def upload_newsagents(file)
		count = 0
		CSV.foreach(file.path, headers: true) do |row|
			if row[0]
				na = FxNewsAgent.new(
					code: row[0],
					agent: row[1],
					fax_email: row[2]
				)
				if na.valid?
					count += 1
					na.save
				else
					Rails.logger.info(na.errors.full_messages)
				end
			else
				Rails.logger.info "No code for #{row[1]}"
			end
		end
		return count
	end

	def upload_se_pricing(file)
		created = []
		errors = []
		good = 0
		CSV.foreach(file.path, headers: true) do |row|
			pubs = FxPublication.contains(row[1])
			if pubs.size > 0
				pub = pubs.first
				se = create_se(pub, row)
				if se.valid?
					se.save					
					good += 1
				else
					errors.push("#{row[1]} SE -- #{se.errors.full_messages}")
				end
			else
				pub = FxPublication.new(name: row[1].strip, parent: row[0].strip, mag: true, se: true, has_se: false)
				if pub.valid?
					pub.save
					created.push(row[1])
					se = create_se(pub, row)
					if se.valid?
						se.save					
						good += 1
					else
						errors.push("#{row[1]} SE -- #{se.errors.full_messages}")
					end
				else
					errors.push("#{row[1]} -- #{pub.errors.full_messages}")
				end
			end
		end
		return { created: created, errors: errors }
	end

	private 

		def dollar_to_decimal(num)
			if num
				return number_with_precision(num.gsub!('$', ''), precision: 2)
			else
				return nil
			end
		end

		def create_se(pub, row)
			se = FxSePricing.new(
				fx_publication: pub, 
				nz_delivery: dollar_to_decimal(row[2]),
				au_delivery: dollar_to_decimal(row[3]),
				row_delivery: dollar_to_decimal(row[4]),
				subscribers: dollar_to_decimal(row[5]),
				standard: dollar_to_decimal(row[6])
			)
		end

end









