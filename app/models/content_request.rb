class ContentRequest < ActiveRecord::Base
	belongs_to :content
	belongs_to :client
end
