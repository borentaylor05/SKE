class FxClassification < ActiveRecord::Base

	scope :contains, -> (name) { where("lower(title) like ? or lower(code) like ?", "%#{name.downcase}%", "%#{name.downcase}%")}

	belongs_to :fx_class_cat

	def self.import(file)
		CSV.foreach(file.path, headers: true, 
			:header_converters => lambda {|f| f.delete(' ')},
			:converters=> lambda {|f| f ? f.strip : nil}) do |row|
				FxClassification.create! row.to_hash
			end
	end

end
