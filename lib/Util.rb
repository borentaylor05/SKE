require 'csv'

class Util

	@@required_fields = [ "first_name", "last_name", "email", "oracle_id", "job_title", "client", "location", "lob" ]

	def self.required_fields
		@@required_fields
	end

	# make sure the hash is in the same order as headers (@@required_fields)
	def self.order_hash(hash)
		return [ hash[:first_name], hash[:last_name], hash[:email], hash[:oracle_id], hash[:job_title], hash[:client], hash[:location], hash[:lob] ]
	end

	def self.user_csv_valid?(row)
		row.count == 8 ? true : false 
	end

	def self.parse_csv_user(row)
		return {
			first_name: row[0],
			last_name: row[1],
			email: row[2],
			oracle_id: row[3],
			job_title: row[4],
			client: row[5],
			lob: row[6],
			location: row[7],
			team_lead_oracle: row[8] ? row[8] : nil
		}
	end

	def self.is_number?(num)
    	true if Float(num) rescue false
  	end

	def self.is_oracle?(num)
		num.length == 7 and num.to_s.match(/\A[+-]?\d+?(\d+)?\Z/) == nil ? false : true
	end

	def self.look_for_oracle(json)
		json["jive"]["profile"].each do |p|
			if p["jive_label"].downcase == "Oracle ID".downcase
				return p["value"]
			end
		end
		return false
	end

	def self.fix_user(json)
		if !json['name']['familyName'] and json['name']
			if json['name']["formatted"].split(" ").count == 1
				json['name']['familyName'] = json['name']["formatted"].split(" ")[0]
				json["name"]["givenName"] = json['name']["formatted"].split(" ")[0]
			else
				json['name']['familyName'] = json['name']["formatted"].split(" ")[1]
				json["name"]["givenName"] = json['name']["formatted"].split(" ")[0]
			end
		end
		return json		
	end

	# takes Jive user and their client, creates array that will be pushed to csv
	def self.create_csv_hash(json, c = false)
		hash = {first_name: "", last_name: "", email: "", client: "", location: "", title: "", lob: "", manager: "", oracle_id: ""}
		if json["name"]["givenName"] and json["name"]["familyName"]
			hash[:last_name] = json["name"]["givenName"] 
			hash[:first_name] = json["name"]["familyName"]
		else
			hash[:first_name] = json["displayName"].split(" ")[0]
			hash[:last_name] = json["displayName"].split(" ")[1]
		end
		if c 
			hash[:client] = c 
		end
		hash[:location] = "APAC" # all for now
		json["jive"]["profile"].each do |p|
			case p["jive_label"]
			when "Title"
				hash[:title] = p["value"]
			when "LOB"
				hash[:lob] = p["value"]
			when "Client" 
				hash[:client] = p["value"]
			when "Manager"
				hash[:manager] = p["value"]
			end
		end
		json["emails"].each do |e|
			if e["primary"]
				hash[:email] = e["value"]
			end
		end
		if self.is_oracle?(json["jive"]["username"])
			hash[:oracle_id] = json["jive"]["username"]
		else
			hash[:oracle_id] = self.look_for_oracle(json)
		end	
		return hash		
	end

	def self.csv_user_is_valid?(user)
		user.each do |key,val|
			if !val 
				return false
			end
		end
		return true
	end

	# inserts / updates user into our database
	# user param is hash from CSV 
	# Contains :jive_id, :first_name, :last_name, :email, :oracle_id, :job_title, :client, :lob, :location
	# NOTE: :jive_id is not in CSV, must be obtained via API call
	def self.create_or_update_from_csv(user)
		# if user is being updated from /ske/user/new
		Rails.logger.info(user)
		if(user.has_key?("client_id") and self.is_number?(user[:client_id]))
			user[:oracle_id] = user[:employee_id]
			user[:job_title] = user[:title]
			client = Client.find_by(id: user[:client_id])
		else 
			client = Client.find_by(name: user[:client].downcase.strip)
		end
		if !client 
			client = Client.find_by(name: self.check_client_map(user[:client].downcase.strip))
		end
		if client and self.csv_user_is_valid?(user)
			u = User.find_by(employee_id: user[:oracle_id].strip)
			if u 
				u.update_attributes(
					client: client,
					employee_id: user[:oracle_id].strip,
					title: user[:job_title].strip,
					location: user[:location].strip,
					lob: user[:lob].strip,
					first_name: user[:first_name],
					last_name: user[:last_name],
					name: "#{user[:first_name]} #{user[:last_name]}"
				)
				return true
			else
				user[:jive_id] = 0 if !user[:jive_id]
				u = User.new(
					jive_id: user[:jive_id].strip,
					employee_id: user[:oracle_id].strip,
					client: client,
					title: user[:job_title].strip,
					location: user[:location].strip,
					lob: user[:lob].strip,
					first_name: user[:first_name],
					last_name: user[:last_name]
				)
				if u.valid?
					u.save
					return true
				else
					Rails.logger.info("ERROR: #{u.errors.full_messages}")
					return false
				end
			end
		else
			Rails.logger.info("Error -> User #{user} is invalid")
			return false
		end
	end

	def self.parse_profile(json, user)
		if user.has_key?("client_id")
			user[:oracle_id] = user[:employee_id]
			user[:job_title] = user[:title]
			user[:client] = Client.find_by(id: user[:client_id]).name
		end
		title_exists = department_exists = location_exists = company_exists = oid_exists = false
		if !json["jive"]["profile"]
			json["jive"]["profile"] = []
		end
		json["jive"]["profile"].each do |p|
			if p["jive_label"] == "Title"
			   title_exists = true
			   p["value"] = "#{user[:job_title]}"
			end
			if p["jive_label"] == "LOB"
			   department_exists = true
			   p["value"] = "#{user[:client].titleize}-#{user[:lob]}"
			end
			if p["jive_label"] == "TeleTech Location"
			   location_exists = true
			   p["value"] = user[:location]
			end
			if p["jive_label"] == "Client"
				company_exists = true
				p["value"] = user[:client].titleize
			end
			if p["jive_label"] == "Oracle ID"
				oid_exists = true
				p["value"] = user[:oracle_id]
			end
		end
		if !title_exists 
			json["jive"]["profile"].push({ jive_label: "Title", value: user[:job_title] })
		end
		if !oid_exists 
			json["jive"]["profile"].push({ jive_label: "Oracle ID", value: user[:oracle_id] })
		end
		if !department_exists
			json["jive"]["profile"].push({ jive_label: "LOB", value: user[:lob] })
		end
		if !location_exists
			json["jive"]["profile"].push({ jive_label: "TeleTech Location", value: user[:location] })
		end
		if !company_exists 
			json["jive"]["profile"].push({ jive_label: "Client", value: user[:client].titleize })
		end
		return json
	end

	def self.verify_csv_hash(hash)
		errors = []
		hash.each do |key, val|
			if val.blank? 
				errors.push("#{key} is a required field.")
			end
		end
		if errors.count == 0
			return "No Errors"
		else
			return errors
		end
	end

	def self.check_client_map(client)
		case client.downcase 
		when "Weight Watchers".downcase
			return "ww"
		when "American Red Cross".downcase
			return "arc"
		when "Fairfax Media".downcase
			return "fairfax"
		end
	end

	def self.create_csv(filename, array, method)
		CSV.open(filename, method, :col_sep => ',') do |csv|
			csv << array
		end	
	end

	def self.get_indices(e, string)
		start, result = -1, []
		result << start while start = (string.index e, start + 1)
		result
	end

	def self.to_readable_mlevel(row)
		return {
			first_name: row[0],
			last_name: row[1],
			email: "#{row[3]}@teletech.com",
			oracle_id: row[3],
			job_title: row[4],
			client: row[5],
			location: "APAC", # all for now
			lob: row[6],
			password: eval(ENV['MLEVEL_PASSWORD_FOR_USER'])
		}
	end

	def self.csv_convert_mlevel(readfile, client)
		client = Client.find_by(name: self.check_client_map(client))
		if client 
			CSV.open("tmp/#{client}_mlevel_users.csv", 'w') do |users|
				User.where(client: client) do |u|
					users << [ user[:first_name], user[:last_name], user[:email], user[:oracle_id], user[:job_title], user[:client], user[:location], user[:lob], user[:password]  ]
				end
			end
		else
			puts "Client not found"
		end
	end

	def self.parse_redelivery_row(row)
		return {
			town: row[1], 		# string
			round_id: row[2],	# string
			redelivery: row[3],	# bool
			cutoff_mf: row[4], 	# string
			cutoff_sat: row[5],	# string
			cutoff_sun: row[6]	# string
		}
	end

	def self.import_simple_gamification(file)
		errors = []
		CSV.foreach(file.path, headers: true) do |row|
			row.each do |r|
				if r == "---"
					r = nil
				end
			end
			if row.count == 5 and row[0]
				user = User.find_by(employee_id: row[0])
				Rails.logger.info(row[0])
				if user 
					if !user.update_attributes(comp_score: row[2], rank: row[3], tier: row[4])
						Rails.logger.info("Error updating.")
						errors.push row[0]
					end
				else
					Rails.logger.info "User #{row[0]} not found."
					errors.push row[0]
				end
			else
				Rails.logger.info("CSV wrong format")
				errors.push "Wrong format at #{row[0]}! - #{row.count} -  "
				return errors
			end
		end
		return errors
	end

end