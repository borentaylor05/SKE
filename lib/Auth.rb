class Auth

	@@social = {:username => ENV['USERNAME'], :password => ENV['PASSWORD']}

	def self.social
		@@social
	end

end