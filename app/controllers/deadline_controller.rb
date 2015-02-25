class DeadlineController < ApplicationController
	skip_before_action :verify_authenticity_token
	before_action :access_check
	after_filter :cors_set_access_control_headers
	after_action :allow_iframe
#	before_action :verify

	def get_deadlines_by_pub
		deadlines = []
		days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
		days.each do |day|
			hash = { day: day, deadlines: Deadline.day(day).contains(params[:pub]) }
			deadlines.push(hash)
		end
		respond({ status: 0, deadlines: deadlines })
	end

	def get_pubs
		pubs = []
		Deadline.uniq.pluck(:publication).each do |p|
			name = p.match('^[^\(]*').to_s.strip
			name = name.match('^[^\-]*').to_s.strip
			if name[0] == "*"
				name[0] = ''
			end
			if !pubs.include?(name)
				pubs.push(name)
			end
		end
		respond({ status: 0, pubs: pubs })
	end

end
