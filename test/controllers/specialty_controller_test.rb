require 'test_helper'

class SpecialtyControllerTest < ActionController::TestCase
  
	test "get specialties" do
		params = {
			client: "arc",
			user: User.first.jive_id
		}
		get :get
	end

	test "add specialties" do
		t = [{n: "billing"}, {n2:"blah"}]
		params = {
			specialties: t.to_json,
			user: User.first.jive_id
		}
		post :add_specialties
	end

end
