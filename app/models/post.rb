class Post < ActiveRecord::Base
	belongs_to :user
	belongs_to :client
	belongs_to :action, touch: true, polymorphic: true
	validates :action, presence: true

	default_scope { order('updated_at DESC') }
end
