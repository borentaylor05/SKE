require 'Jive'
desc "This task is called by the Heroku scheduler add-on"
task :move_doc => :environment do
  puts "Updating feed..."
  resp = Jive.grab("#{Jive.dev_url}/contents/1048", Jive.dev_auth)
  resp["parent"] = "http://localhost:8080/api/core/v3/places/1002"
  updated = Jive.update("#{Jive.dev_url}/contents/1048", resp, Jive.dev_auth)
  puts updated
  puts "done."
end

# BELOW = TESTS

task :get_doc => :environment do
	resp = Jive.grab("https://social.teletech.com/api/core/v3/contents/938729", Jive.auth)
	puts resp
end

task :generate_token => :environment do
	token = Digest::SHA1.hexdigest([Time.now, rand].join)[0...10]
	while WwCodeInfo.exists?(token: token)
		token = Digest::SHA1.hexdigest([Time.now, rand].join)[0...10]
	end
	puts token
end

task :reset_codes => :environment do 
	WwCode.all.each do |w| 
		w.used = false
		w.save
	end
	WwCodeInfo.destroy_all
end

task :empty_codes => :environment do
	WwCodeInfo.destroy_all
	WwCode.destroy_all
end

task :pr_string_to_bool => :environment do 
	AToZEntry.all.each do |e|
		 bool = e.PRs == "YES" ? true : false
		 e.update_attributes(PR_bool: bool)
	end
end

task :spanish_string_to_bool => :environment do 
	AToZEntry.all.each do |e|
		 bool = e.Spanish == "Y" ? true : false
		 e.update_attributes(Spanish_bool: bool)
	end
end

