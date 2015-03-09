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
				json['name']['familyName'] = json['name']["formatted"].split(" ")[0]
				json["name"]["givenName"] = json['name']["formatted"].split(" ")[1]
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