class WwCode < ActiveRecord::Base

	has_one :ww_code_info
	validates_uniqueness_of :code_num
	default_scope { order('updated_at DESC') }

end
