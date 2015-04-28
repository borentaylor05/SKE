class AToZEntry < ActiveRecord::Base

	default_scope { order('topic ASC') }

	scope :contains, -> (name) { where("topic like ?", "%#{name}%")}

	def self.import(file)
		cdc = CDC.new('dev')
		cdc.import_a_to_z(file.path)
	end
	
end
