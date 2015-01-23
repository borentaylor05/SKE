class AToZEntry < ActiveRecord::Base

	default_scope { order('topic ASC') }

	def self.import(file)
		CSV.foreach(file.path, headers: true, 
			:header_converters => lambda {|f| f.delete(' ')},
			:converters=> lambda {|f| f ? f.strip : nil}) do |row|
				AToZEntry.create! row.to_hash
			end
	end
	
end
