class FxMagPricing < ActiveRecord::Base
	validates :fx_publication_id, presence: true
	belongs_to :fx_publication
end
