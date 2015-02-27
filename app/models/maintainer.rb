class Maintainer < ActiveRecord::Base
	include ActionView::Helpers::DateHelper
	require 'Jive'
	belongs_to :user
	belongs_to :client
	belongs_to :admin
	belongs_to :ticket, touch: true, polymorphic: true
	validates :user, presence: true, unless: -> (maintainer){maintainer.admin.present?}
	validates :admin, presence: true, unless: -> (maintainer){maintainer.user.present?}
	validates :ticket, presence: true
#	validates :client, presence: true
	
	default_scope { order('updated_at DESC') }


	def makeRelevant
		Rails.logger.info("MAIN -----> #{self.inspect}")
		case self.ticket_type
		when "ArticleRequest"
			hash = {
				user: self.user,
				type: "Article Request",
				resolved: self.resolved,
				url: self.ticket.file_url,
				title: self.ticket.title,
				body: self.ticket.summary 
			}
		when "CommentIssue"
			com = Jive.grab("#{Jive.current}/comments/#{self.ticket.old_comment.api_id}", Auth.current)
			Rails.logger.info("COM ----------> #{com["error"]}")
			if com["error"] # comment was deleted
				self.update_attributes(do_delete: true)
				return hash = { title: "DELETED" } 
			end
			hash = {
				user: self.user,
				type: "Comment",
				resolved: self.resolved,
				ticket_status: self.ticket.old_comment.resolved,
				url: com["resources"]["html"]["ref"],
				title: com["subject"],
				body: com["content"]["text"]
			}
		end
		hash[:updated_at] = "#{time_ago_in_words(self.updated_at)} ago"
		hash[:id] = self.id
		hash[:pcf] = self.pcf
		hash[:training_impact] = self.training_impact
		hash[:decision] = self.decision
		hash[:response] = self.response
		return hash
	end

end
