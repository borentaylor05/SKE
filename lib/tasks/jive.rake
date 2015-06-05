require 'Jive'
require 'Util'
require 'Auth'
require 'csv'

task :move_doc => :environment do
	puts "Updating feed..."
	resp = Jive.grab("#{Jive.dev_url}/contents/1048", Jive.dev_auth)
	resp["parent"] = "http://localhost:8080/api/core/v3/places/1002"
	updated = Jive.update("#{Jive.dev_url}/contents/1048", resp, Jive.dev_auth)
	puts updated
	puts "done."
end

task create_users: :environment do 
	# users = TempUser.all
	CSV.foreach("telstra_roster_051515.csv", headers: true) do |row|
		user = Util.parse_csv_user(row)
		# create_user params -> user: user hash, to_db: boolean (do you want user saved to local db)
	 	Jive.create_user(user, false) 
	end
end

task :delete_users => :environment do
	user_ids = [2014,2015,2018,2019,2029,2030,2031,2032,2033,2034,2035,2036,2037,2038,2039,2040,2041,2064,2103,2268,2699,2879,2058,2060,2063,2069,2070,2071,2072,2075,2076,2079,2080,2081,2082,2083,2085,2087,2090,2094,2095,2096,2097,2098,2101,2105,2106,2107,2108,2111,2117,2118,2120,2121,2123,2125,2128,2129,2132,2133,2134,2135,2136,2137,2138,2139,2141,2142,2143,2144,2145,2146,2147,2148,2149,2150,2151,2152,2153,2154,2155,2156,2157,2158,2159,2160,2161,2162,2163,2164,2165,2166,2167,2169,2171,2172,2173,2175,2176,2179,2180,2181,2183,2184,2185,2189,2190,2191,2192,2195,2197,2200,2203,2205,2207,2208,2209,2211,2213,2218,2219,2225,2226,2229,2230,2231,2233,2234,2235,2239,2246,2250,2251,2252,2254,2255,2256,2257,2259,2260,2261,2262,2263,2264,2265,2269,2270,2271,2273,2274,2277,2278,2280,2281,2282,2284,2285,2286,2287,2288,2290,2291,2292,2294,2296,2297,2298,2299,2301,2302,2303,2304,2309,2310,2313,2316,2317,2318,2321,2323,2326,2329,2331,2332,2334,2335,2336,2337,2339,2342,2343,2344,2345,2346,2349,2350,2351,2353,2355,2356,2359,2360,2361,2362,2363,2366,2370,2372,2373,2374,2376,2380,2381,2382,2383,2385,2388,2389,2390,2391,2392,2394,2396,2402,2403,2408,2410,2411,2413,2415,2416,2417,2418,2423,2424,2425,2426,2428,2431,2433,2435,2438,2439,2441,2444,2445,2446,2447,2451,2452,2453,2455,2458,2459,2460,2461,2463,2465,2466,2467,2468,2469,2471,2475,2476,2477,2479,2480,2481,2482,2484,2485,2486,2487,2488,2489,2490,2491,2492,2493,2494,2495,2496,2497,2498,2499,2500,2501,2503,2504,2505,2507,2511,2513,2514,2516,2517,2518,2519,2520,2521,2523,2524,2525,2526,2527,2528,2529,2530,2532,2533,2534,2535,2537,2539,2540,2541,2542,2543,2544,2545,2547,2548,2552,2553,2554,2557,2559,2563,2566,2567,2568,2569,2570,2571,2572,2576,2578,2579,2580,2583,2584,2585,2586,2587,2588,2589,2590,2592,2595,2596,2600,2602,2603,2605,2606,2607,2608,2611,2612,2613,2614,2617,2618,2619,2620,2623,2624,2625,2627,2628,2629,2630,2632,2633,2634,2635,2636,2638,2639,2640,2641,2642,2645,2647,2649,2650,2651,2653,2656,2658,2659,2660,2662,2670,2671,2673,2675,2676,2677,2678,2679,2680,2681,2684,2686,2702,2746,2747,2748,2749,2750,2751,2752,2754,2755,2756,2759,2760,2762,2763,2765,2771,2795,2797,2798,2806,2807,2810,2812,2813,2814,2817,2820,2822,2824,2827,2828,2829,2831,2832,2835,2837,2840,2841,2843,2844,2847,2850,2851,2874,2877,2878,2895,2896,2898,2899,2900,2901,2910,2911,2913,2915,2917,2921,2922,2926,2927,2928,2929,2931,2934,2936,2938,2939,2940,2941,2943,2944,2945,2946,2948,2949,2954,2958,2960,2962,2966,2971,2976,2978,2979,2982,2985,2986,2992,2993,2994,2995,2998,3006,3008,3009,3010,3011,3013,3014,3029,3046,3055,3056,3084,3086,3103,3112,3114]
	user_ids.each do |u|
		puts "Deleting #{u}"
		deleted = Jive.remove("#{Jive.fairpoint_url}/people/#{u}", Auth.fairpoint)
		if deleted["error"]
			puts deleted["error"]
		end
	end
end

task check_users: :environment do 
#	user_ids = [2014,2015,2018,2019,2029,2030,2031,2032,2033,2034,2035,2036,2037,2038,2039,2040,2041,2064,2103,2268,2699,2879,2058,2060,2063,2069,2070,2071,2072,2075,2076,2079,2080,2081,2082,2083,2085,2087,2090,2094,2095,2096,2097,2098,2101,2105,2106,2107,2108,2111,2117,2118,2120,2121,2123,2125,2128,2129,2132,2133,2134,2135,2136,2137,2138,2139,2141,2142,2143,2144,2145,2146,2147,2148,2149,2150,2151,2152,2153,2154,2155,2156,2157,2158,2159,2160,2161,2162,2163,2164,2165,2166,2167,2169,2171,2172,2173,2175,2176,2179,2180,2181,2183,2184,2185,2189,2190,2191,2192,2195,2197,2200,2203,2205,2207,2208,2209,2211,2213,2218,2219,2225,2226,2229,2230,2231,2233,2234,2235,2239,2246,2250,2251,2252,2254,2255,2256,2257,2259,2260,2261,2262,2263,2264,2265,2269,2270,2271,2273,2274,2277,2278,2280,2281,2282,2284,2285,2286,2287,2288,2290,2291,2292,2294,2296,2297,2298,2299,2301,2302,2303,2304,2309,2310,2313,2316,2317,2318,2321,2323,2326,2329,2331,2332,2334,2335,2336,2337,2339,2342,2343,2344,2345,2346,2349,2350,2351,2353,2355,2356,2359,2360,2361,2362,2363,2366,2370,2372,2373,2374,2376,2380,2381,2382,2383,2385,2388,2389,2390,2391,2392,2394,2396,2402,2403,2408,2410,2411,2413,2415,2416,2417,2418,2423,2424,2425,2426,2428,2431,2433,2435,2438,2439,2441,2444,2445,2446,2447,2451,2452,2453,2455,2458,2459,2460,2461,2463,2465,2466,2467,2468,2469,2471,2475,2476,2477,2479,2480,2481,2482,2484,2485,2486,2487,2488,2489,2490,2491,2492,2493,2494,2495,2496,2497,2498,2499,2500,2501,2503,2504,2505,2507,2511,2513,2514,2516,2517,2518,2519,2520,2521,2523,2524,2525,2526,2527,2528,2529,2530,2532,2533,2534,2535,2537,2539,2540,2541,2542,2543,2544,2545,2547,2548,2552,2553,2554,2557,2559,2563,2566,2567,2568,2569,2570,2571,2572,2576,2578,2579,2580,2583,2584,2585,2586,2587,2588,2589,2590,2592,2595,2596,2600,2602,2603,2605,2606,2607,2608,2611,2612,2613,2614,2617,2618,2619,2620,2623,2624,2625,2627,2628,2629,2630,2632,2633,2634,2635,2636,2638,2639,2640,2641,2642,2645,2647,2649,2650,2651,2653,2656,2658,2659,2660,2662,2670,2671,2673,2675,2676,2677,2678,2679,2680,2681,2684,2686,2702,2746,2747,2748,2749,2750,2751,2752,2754,2755,2756,2759,2760,2762,2763,2765,2771,2795,2797,2798,2806,2807,2810,2812,2813,2814,2817,2820,2822,2824,2827,2828,2829,2831,2832,2835,2837,2840,2841,2843,2844,2847,2850,2851,2874,2877,2878,2895,2896,2898,2899,2900,2901,2910,2911,2913,2915,2917,2921,2922,2926,2927,2928,2929,2931,2934,2936,2938,2939,2940,2941,2943,2944,2945,2946,2948,2949,2954,2958,2960,2962,2966,2971,2976,2978,2979,2982,2985,2986,2992,2993,2994,2995,2998,3006,3008,3009,3010,3011,3013,3014,3029,3046,3055,3056,3084,3086,3103,3112,3114]
	
	TempUser.all.each do |u|
		json = Jive.grab("#{Jive.social}/people/username/#{u.username}", Auth.social)
		if json["error"]
			puts "#{json["error"]["message"]}"
		else
			puts "User -- #{u.username} -- exists! --> #{json['jive']['enabled']}"
		end
	end
end

task :deactivate_users => :environment do
	user_ids = [] # this needs an array of Jive IDs
	user_ids.each do |u|
		resp = Jive.grab("#{Jive.fairpoint_url}/people/#{u}", Auth.fairpoint)
		if resp["error"]
			puts resp['error']
		end
		resp["jive"]["enabled"] = false
		# jive doesn't like Canadian timezone. To prevent error, I changed all to valid timezone
		resp["jive"]["timeZone"] = "America/Los_Angeles"
		updated = Jive.update("#{Jive.fairpoint_url}/people/#{u}", resp, Auth.fairpoint)
		if updated['error']
			puts "ERROR ------------------------> #{updated['error']}"
		else
			puts "Updated: #{updated['id']}, Active: #{updated['jive']['enabled']}"
		end
	end
	
end

task :follow_docs_in_place => :environment do
	# needs instance, auth and place ID
	 docs = Jive.get_docs_from_place(Jive.social, Auth.social, 352192)
	 puts "Adding #{docs.count} documents"
	 # needs stream ID, docs array and Jive authentication object
	 Jive.add_to_stream(288687, docs, Auth.social)
end

task :update_users_and_change_username_to_oracle_id => :environment do
	file = "test_upload.csv"
	jive = {
		auth: Auth.social,
		url: Jive.social
	}
	if Util.user_csv_valid?(CSV.open(file).first)
		CSV.foreach(file, headers: true) do |row|
			user = Util.parse_csv_user(row)
			json = Jive.grab("#{jive[:url]}/people/username/#{user[:oracle_id]}", jive[:auth])
			if json["error"]
				# username is not oracle ID
				matches = Jive.people_search("#{user[:first_name]} #{user[:last_name]}", jive)
				if matches["list"].count == 1
					json = Jive.change_username_to_oracle_id(matches["list"][0]["id"], user[:oracle_id], jive)
					user[:jive_id] = json["id"]
					if json
						Util.create_or_update_from_csv(user) # creates in local db
						Jive.update_user_with_csv_data(json, user, jive) # creates in Jive 
					else
						puts "Error --------------> Error changing username to oracle_id"
					end
					puts "Can Fix: #{user[:first_name]} #{user[:last_name]}"
				else
					puts "Must fix manually ---------------> #{user[:first_name]} #{user[:last_name]}"
				end
			else
				# user has oracle ID as username
				user[:jive_id] = json["id"]
				Util.create_or_update_from_csv(user) # creates in local db
				Jive.update_user_with_csv_data(json, user, jive) # creates in Jive 
				# "#{user[:first_name]} #{user[:last_name]} is good to go!"
			end
		end
	else
		puts "Invalid User CSV --> Num Rows = #{CSV.open(file).first.count} "
	end
end

# takes users from temp table (usually pulled from a spreadsheet) and puts them in the users table
task :migrate_users, [:fromTable, :client_name, :backwards_name] => :environment do |t, args|
	client = Client.find_by(name: args[:client_name].downcase)
	if client.nil?
		puts "ERROR ---> Client not found  "
	else
		Object.const_get(args[:fromTable]).all.each do |u|
			if args[:backwards_name] == "true"
				name = Jive.fix_backwards_name(u.name)
			else
				name = u.name
			end
			user = User.new(jive_id: u.jive_id, name: name, lob: u.lob, client: client, title: u.title, location: u.location, employee_id: u.oracle_id)
			if user.valid?
				user.save
			else
				puts "ERROR -----> #{user.errors.full_messages}"
			end
		end
	end
end

task :get_secGroup_users, [:group] => :environment do |t,args|
	json = Jive.grab("#{Jive.ww_coaches}/securityGroups/#{args[:group]}/members?count=100", Auth.ww_coaches)
	while json && json["links"]
			json["list"].each do |u|
				email = ""
				u["emails"].each do |e|
					if e["primary"] == true
						email = e["value"]
					end
				end
				puts "#{email} \t #{u["jive"]["username"]}"
			end
		if json["links"]["next"]
			json = Jive.grab(json["links"]["next"], Auth.ww_coaches)
		else
			break
		end
	end
end

desc "Delete Maintainers with do_delete == true"
task :delete_maintainers => :environment do
	Maintainer.where(do_delete: true).destroy_all
end

task :clear_comments => :environment do 
	OldContent.destroy_all
	OldComment.destroy_all
	Maintainer.where(ticket_type: "CommentIssue").destroy_all
end

task :get_users => :environment do 
	si = 0
	json = Jive.grab("#{Jive.social}/people?count=100&startIndex=#{si}", Auth.social)
	while json["list"] && json["list"].count > 0
		users = json["list"]
		CSV.open("tmp/users.csv", "a+", :col_sep => ',') do |csv|
			users.each do |u|
				csv << [u["id"], u["jive"]["username"]]
				puts "Processing #{u["id"]}" 
			end
		end
		si = si + 100
		json = Jive.grab("#{Jive.social}/people?count=100&startIndex=#{si}", Auth.social)
	end

end

task :create_user_csv, [:file] => :environment do |t,args|
	if !args[:file].empty?
		# kgrimm -> no oracle ID
		usernames = ['3151641', 'darby.conway', 'lindsay.keith', 'alecvillamarin', '2124496', '2121809', '2121597', 'lynettekoronowski', '3170083']
		Util.create_csv(args[:file], Util.required_fields, "a")
		usernames.each do |u|
			json = Jive.grab("#{Jive.social}/people/username/#{u}", Auth.social)
			hash = Util.create_csv_hash(json, 'Admin')
			Util.create_csv(args[:file], Util.order_hash(hash), "a")
		end
	else
		puts "You must supply a file name -> update_users[:filename]"
	end
end

task :update_user => :environment do 
	json = Jive.grab("#{Jive.social}/people/username/123456", Auth.social)
	json = Util.fix_user(json)
	if !json["jive"]["profile"]
		json["jive"]["profile"] = []
	end
	json["jive"]["profile"].push({ "value" => "TEST", "jive_label" => "Locale" })
	resp = Jive.update("#{Jive.social}/people/#{json["id"]}", json, Auth.social)
	if resp.code > 399
		puts "ERROR: #{resp.code} -> #{resp.message} -> #{resp.parsed_response}"
	else
		puts resp.parsed_response
	end
end

task check_csv_users: :environment do 
	CSV.foreach('roster_031715.csv', headers: true) do |row|
		json = Jive.grab("#{Jive.social}/people/username/#{row[3]}", Auth.social)
		if json and !json["error"]
			jive_id = json["id"]
			json["jive"]["profile"].each do |p|
				if p["jive_label"] == "Title"
				   title_exists = true
				   p["value"] = "#{row[4]}"
				end
			end
			resp = Jive.update("#{Jive.social}/people/#{jive_id}", json, Auth.social)
			if resp["error"] and resp 
				puts "#{row[0]} #{row[1]} - resp['error']"
			end
		end
	end
end


task get_wwc_followers: :environment do 
	places = [
		{ name: "24-7 Click to Chat Knowledge Base", id: 2007, type: 14, users: [] },
		{ name: "Personal Coaching Knowledge Base", id: 2006, type: 14, users: [] },
		{ name: "Coaches Support Bridge", id: 1033, type: 700, users: [] },
		{ name: "Coaches Tech-Escalation Bridge", id: 1034, type: 700, users: [] }
	]

	places.each do |p|
		json = Jive.grab("#{Jive.ww_coaches}/places?filter=entityDescriptor(#{p[:type]},#{p[:id]})", Auth.ww_coaches)
		if json and json["error"]
			puts json["error"]
		else
			json = Jive.grab("#{json["list"][0]["resources"]["followers"]["ref"]}?count=100", Auth.ww_coaches)
			while json and json["list"].count > 0
				json["list"].each { |u| p[:users].push({ username: u["jive"]["username"], name: u["name"]["formatted"] }) }
				if json["links"]["next"]
					json = Jive.grab(json["links"]["next"], Auth.ww_coaches)
				else
					break
				end
			end
		end
	end
	
	places.each do |p|
		CSV.open("tmp/#{p[:name]}-followers.csv", 'w') do |file|
			p[:users].each do |u|	
				file << [ u[:username], u[:name] ]
			end
		end
	end
end

task get_non_oracle_ids: :environment do 
	jive = { url: Jive.social, auth: Auth.social }
	CSV.foreach("ww_roster_trunc.csv", headers: true) do |row|
		user = {
			oracle_id: row[0],
			name: "#{row[2]} #{row[1]}"
		}
		resp = Jive.grab("#{jive[:url]}/people/username/#{user[:oracle_id]}", jive[:auth])
		if resp["error"]
			puts "#{user[:name]} - #{user[:oracle_id]}: \t #{resp["error"]}"
		end
	end
end

task hash_test: :environment do 
	hash = {}
	string = "a test"
	hash[string] = "HELLO WORLD"
end 

task add_to_sec_group: :environment do 
	ids = []
	jive = { url: Jive.social, auth: Auth.social }
	CSV.foreach("ww_sec_groups.csv", headers: true) do |row|
	#	user = Util.parse_csv_user(row)	
		if row[0]
		#	resp = Jive.grab("#{jive[:url]}/people/username/#{user[:oracle_id]}", jive[:auth])
		resp = Jive.grab("#{jive[:url]}/people/username/#{row[0]}", jive[:auth])
			if resp["id"]				
	#			puts "Added #{user[:oracle_id]}"
				puts "Added #{row[0]}"
				ids.push(resp["id"])
			else
				puts resp
			end
		end
	end
	puts Jive.add_to_sec_group(2636,ids, jive)
end

task add_clients_to_sec_group: :environment do 
	ids = []
	jive = { url: Jive.social, auth: Auth.social }
	clients = Client.where(name: ["cdc", "fairfax", "all"])
	User.where(client: clients).each do |u|
		if u.employee_id
			resp = Jive.grab("#{jive[:url]}/people/username/#{u.employee_id}", jive[:auth])
			if resp and resp["id"]				
				puts "Added #{u.employee_id}"
				ids.push(resp["id"])
			else
				puts resp
			end
		end
	end
	puts Jive.add_to_sec_group(2637,ids, jive)
end

task check_oids: :environment do 
	CSV.foreach("telstra_roster_051515.csv", headers: true) do |row|
		user = Util.parse_csv_user(row)	
		Jive.check_user(user[:oracle_id])
	end
end

task check_sec_group: :environment do 
	puts Jive.grab("#{Jive.social}/securityGroups/2630/members", Auth.social)["list"].count
end

task set_telstra_passwords: :environment do 
	jive = { url: Jive.social, auth: Auth.social }
	CSV.foreach("telstra_roster_051515.csv", headers: true) do |row|
		user = Util.parse_csv_user(row)	
		json = Jive.grab("#{jive[:url]}/people/username/#{user[:oracle_id]}", jive[:auth])
		if json["id"]
			if Jive.update_user_everywhere(json, user, jive)
				puts "Created #{user[:oracle_id]}"
			else
				puts "ERROR ---> #{user[:oracle_id]}"
			end
		else
			puts "ERROR --------> #{json}"
		end
	end
end