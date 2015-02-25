class OldComment < ActiveRecord::Base
	belongs_to :old_content
	has_one :maintainer, as: :ticket
end
