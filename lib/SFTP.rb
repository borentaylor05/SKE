require 'net/ssh'
require 'net/sftp'
class SFTP
# blah blah comment
# asdsaldklsadkas;ldk
	def initialize(org)
		case org
		when 'mlevel'
			@host = ENV['MLEVEL_FTP_HOST']
			@username = ENV['MLEVEL_FTP_USERNAME']
			@password = ENV['MLEVEL_FTP_PASSWORD']
			@port = 10022
		end
	end

	def send(local_path)
		Net::SFTP.start(@host, @username , { password: @password, port: @port } ) do |sftp|
			sftp.upload!(local_path, "/fairfax_users_mlevel2.csv")
		end
	end

end