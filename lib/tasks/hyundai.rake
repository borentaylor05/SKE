require 'csv'
require 'Util'
require 'Jive'
require 'Jive2'
require 'Auth'


task add_oracle_ids: :environment do
	jive = Jive2.new('social')
	jive_ids = []
	CSV.foreach("hyundai_ids.csv", headers: false) do |row|
		jive_ids.push row[0]
	end
	puts jive.create("/securityGroups/2639/members", jive_ids)
end