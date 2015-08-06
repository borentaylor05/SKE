class AToZEntry < ActiveRecord::Base

	default_scope { order('topic ASC') }

	scope :contains, -> (name) { where("lower(topic) like ? or lower(aka) like ?", "%#{name.downcase}%", "%#{name.downcase}%")}

	def self.import(file)
		cdc = CDC.new('social')
		cdc.import_a_to_z(file.path)
	end
	
end
