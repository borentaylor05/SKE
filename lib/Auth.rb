class Auth

	# SKE is currently set to demo site!!!!
	@@current = {:username => ENV['SKE_USER'], :password => ENV['SKE_PASSWORD']}
	@@social = {:username => ENV['USERNAME'], :password => ENV['PASSWORD']}
	@@fairpoint = { username: ENV['FP_USERNAME'], password: ENV['FP_PASSWORD'] }
	@@dev = { username: 'admin', password: 'admin' }
	

	def self.social
		@@social
	end

	def self.fairpoint
		@@fairpoint
	end

	def self.dev
		@@dev
	end

	def self.current
		@@current
	end

end