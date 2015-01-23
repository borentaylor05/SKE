require 'test_helper'

class UserControllerTest < ActionController::TestCase
  test "new user route" do 
  	params = {
  		jive_id: User.first.jive_id,
  		employee_id: User.first.employee_id,
  		client: Client.first.name
  	}
  	post :create, params
  end

  test "update client" do
  	params = {
  		jive_id: User.first.jive_id,
  		employee_id: User.first.employee_id,
  		client: Client.first.name
  	}
  	post :update_client, params
  end

  test "check user init" do  
    params = {
      user: User.first.jive_id
    }
    get :check_init, params
  end

end
