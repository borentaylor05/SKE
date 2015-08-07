class AToZEntry < ActiveRecord::Base

	default_scope { order('topic ASC') }

	scope :contains, -> (name) { where("upper(topic) like ? or upper(aka) like ?", "%#{name.upcase}%", "%#{name.upcase}%")}

	def self.import(file)
		cdc = CDC.new('social')
		cdc.import_a_to_z(file.path)
	end
	
end
