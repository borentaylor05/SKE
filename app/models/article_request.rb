class ArticleRequest < ActiveRecord::Base

	belongs_to :client

	validates :title, presence: true
	validates :summary, presence: true
	
	has_one :maintainer, as: :ticket

end
