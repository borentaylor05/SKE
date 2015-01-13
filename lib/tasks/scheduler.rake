require 'Jive'
desc "This task is called by the Heroku scheduler add-on"
task :move_doc => :environment do
  puts "Updating feed..."
  resp = Jive.grab("#{Jive.dev_url}/contents/1048", Jive.auth)
  resp["parent"] = "http://localhost:8080/api/core/v3/places/1002"
  updated = Jive.update("#{Jive.dev_url}/contents/1048", resp, Jive.auth)
  puts updated
  puts "done."
end

task :get_doc => :environment do
	puts Jive.auth
	resp = Jive.grab("https://social.teletech.com/api/core/v3/contents/938729", Jive.auth)
	puts resp
end