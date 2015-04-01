class TempUser < ActiveRecord::Base
	require 'csv'
	require 'Jive'
	require 'Util'
	require 'Auth'

	def self.import_db_only(file)
		results = {
			good: 0,
			bad: 0
		}
		if Util.user_csv_valid?(CSV.open(file.path).first)
			CSV.foreach(file.path, headers: true) do |row|
				user = Util.parse_csv_user(row)
				user[:jive_id] = '0'
				if Util.create_or_update_from_csv(user)
					results[:good] += 1
				else
					results[:bad] += 1
				end
			end
			return results
		else
			return "Bad CSV -> #{CSV.open(file.path).first.count}"
		end
	end

	def self.import(file)
		results = {
			errors: [],
			fixed: [],
			good: [],
			manual: [],
			users: [],
			totals: {}
		}
		jive = {
			auth: Auth.dev,
			url: Jive.dev_url
		}
		if Util.user_csv_valid?(CSV.open(file.path).first)
			CSV.foreach(file.path, headers: true) do |row|
				user = Util.parse_csv_user(row)
				json = Jive.grab("#{jive[:url]}/people/username/#{user[:oracle_id]}", jive[:auth])
				if json["error"]
					# username is not oracle ID
					matches = Jive.people_search("#{user[:first_name]} #{user[:last_name]}", jive)
					if matches["list"].count == 1
						json = Jive.change_username_to_oracle_id(matches["list"][0]["id"], user[:oracle_id], jive)
						user[:jive_id] = json["id"]
						if json
							json = Util.fix_user(json)
							Util.create_or_update_from_csv(user) # creates in local db
							resp = Jive.update_user_with_csv_data(json, user, jive) # creates in Jive 
							if resp["error"]
								results[:errors].push("#{user[:first_name]} #{user[:last_name]} - #{resp}")
							else
								results[:fixed].push("#{user[:first_name]} #{user[:last_name]}")
							end
						else
							results[:errors].push("Error for #{user[:first_name]} #{user[:last_name]} Error changing username to oracle_id")
						end
					else
						results[:manual].push("#{user[:first_name]} #{user[:last_name]}")
					end
				else
					# user has oracle ID as username
					user[:jive_id] = json["id"]
					Util.create_or_update_from_csv(user) # creates in local db
					resp = Jive.update_user_with_csv_data(json, user, jive) # creates in Jive 
					results[:users].push(json)
					if resp["error"]
						results[:errors].push("#{user[:first_name]} #{user[:last_name]} - #{resp}")
					else
						results[:good].push("#{user[:first_name]} #{user[:last_name]}")
					end
				end
			end
		else
			results[:errors].push("Invalid User CSV --> Num Rows = #{CSV.open(file.path).first.count}")
		end
		results[:totals][:errors] = results[:errors].count
		results[:totals][:good] = results[:good].count
		results[:totals][:manual] = results[:manual].count
		results[:totals][:fixed] = results[:fixed].count
		results[:totals][:all] = results[:errors].count + results[:good].count + results[:manual].count + results[:fixed].count
		return results
	end
end
