class FxClassCat < ActiveRecord::Base

	default_scope { order('name ASC') }

	has_many :fx_classifications

end
