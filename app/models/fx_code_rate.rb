class FxCodeRate < ActiveRecord::Base

	validates :schedule, presence: true
	validates :year_code, presence: true
	validates :year_rate, presence: true
	validates :month_code, presence: true
	validates :month_rate, presence: true
	validates :three_day, :inclusion => {:in => [true, false]}
	validates :fx_publication_id, presence: true

	belongs_to :fx_publication

end
