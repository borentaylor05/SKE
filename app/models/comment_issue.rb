class CommentIssue < ActiveRecord::Base

	belongs_to :old_comment

	has_one :maintainer, as: :ticket

end
