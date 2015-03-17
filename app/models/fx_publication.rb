class FxPublication < ActiveRecord::Base
	validates :name, presence: true
end
