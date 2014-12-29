class IssueController < ApplicationController
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers

	def webhook_create_issue
		i = Issue.new(
			created_by: User.find_by(jive_id: params[:created_by].to_s).id,
			content: Content.find_by(api_id: params[:doc]),
			api_id: params[:api_id],
			issue_type: params[:type],
			url: params[:url],
			summary: params[:message],
			resolved: false
		)
		i.title = i.content.title
		p = Post.new(user_id: i.created_by, client_id: i.creator.client.id, action: i)
		i.post = p
		Rails.logger.debug("HEEEEERRREEEE #{p.inspect}")
		if i.valid? && p.valid?
			i.save
			p.save
			respond({status: 1, message: "Issue Created"})
		else
			respond({ status: 0, message: "Issue: #{i.errors.full_messages}, Post: #{p.errors.full_messages}" })
		end
	end

	def resolve
		i = Issue.find(params[:id])
		i.update_attributes(resolved: true, resolver: User.find_by(jive_id: params[:resolved_by]), resolved_at: Time.now)
		respond(i)
	end

	def unresolve
		i = Issue.find(params[:id])
		i.update_attributes(resolved: false)
		respond(i)
	end

end
