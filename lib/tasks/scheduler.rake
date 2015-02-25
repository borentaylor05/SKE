

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

task :deadline_test => :environment do 
	pubs = []
	Deadline.uniq.pluck(:publication).each do |p|
		name = p.match('^[^\(]*').to_s.strip
		name = name.match('^[^\-]*').to_s.strip
		if name[0] == "*"
			name[0] = ''
		end
		if !pubs.include?(name)
			pubs.push(name)
			puts name
		end
	end
end

task :unacknowledge => :environment do
	MessageTracker.all.each do |t|
		t.acknowledged = false
		t.save
	end
end



