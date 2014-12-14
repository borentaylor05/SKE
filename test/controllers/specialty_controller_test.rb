require 'test_helper'

class SpecialtyControllerTest < ActionController::TestCase
  
	test "get specialties" do
		params = {
			client: "arc"
		}
		get :get
	end

end
