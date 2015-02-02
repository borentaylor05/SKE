class Deadline < ActiveRecord::Base
	default_scope { order('publication ASC') }
	scope :contains, -> (name) { where("lower(publication) like ?", "%#{name.downcase}%")}
	scope :day, -> (name) { where("lower(close_day) like ?", "%#{name.downcase}%")}

	def self.import(file)
		CSV.foreach(file.path, headers: true, 
			:header_converters => lambda {|f| f.delete(' ')},
			:converters=> lambda {|f| f ? f.strip : nil}) do |row|
				Deadline.create! row.to_hash
			end
	end

end
