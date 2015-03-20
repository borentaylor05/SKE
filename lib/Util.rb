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
			location: row[7]
		}
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
		client = Client.find_by(name: user[:client].downcase.strip)
		if !client 
			client = self.check_client_map(client)
		end
		if client and self.csv_user_is_valid?(user)
			u = User.find_by(jive_id: user[:jive_id].strip)
			if u 
				u.update_attributes(
					client: client,
					employee_id: user[:oracle_id].strip,
					title: user[:job_title].strip,
					location: user[:location].strip,
					lob: user[:lob].strip
				)
			else
				u = User.new(
					jive_id: user[:jive_id].strip,
					employee_id: user[:oracle_id].strip,
					client: client,
					title: user[:job_title].strip,
					location: user[:location].strip,
					lob: user[:lob].strip
				)
				if u.valid?
					u.save
				else
					puts "ERROR: #{u.errors.full_messages}"
				end
			end
		else
			puts "Error -> User #{user} is invalid"
		end
	end

	def self.parse_profile(json, user)
		title_exists = department_exists = location_exists = company_exists = false
		if !json["jive"]["profile"]
			json["jive"]["profile"] = []
		end
		json["jive"]["profile"].each do |p|
			if p["jive_label"] == "Title"
			   title_exists = true
			   p["value"] = "#{user[:job_title]}"
			end
			if p["jive_label"] == "Department"
			   department_exists = true
			   p["value"] = "#{user[:client].titleize}-#{user[:lob]}"
			end
			if p["jive_label"] == "TeleTech Location"
			   location_exists = true
			   p["value"] = user[:location]
			end
			if p["jive_label"] == "Company"
				company_exists = true
				p["value"] = user[:client].titleize
			end
		end
		if !title_exists 
			json["jive"]["profile"].push({ jive_label: "Title", value: user[:job_title] })
		end
		if !department_exists
			json["jive"]["profile"].push({ jive_label: "Department", value: user[:lob] })
		end
		if !location_exists
			json["jive"]["profile"].push({ jive_label: "TeleTech Location", value: user[:location] })
		end
		if !company_exists 
			json["jive"]["profile"].push({ jive_label: "Company", value: user[:client] })
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
		end
	end

	# method -> a+ for append, 'wb' = append
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

end