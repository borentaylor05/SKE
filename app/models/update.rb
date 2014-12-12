class Update < ActiveRecord::Base
	has_one :post, as: :action
	belongs_to :user
	belongs_to :client
end
