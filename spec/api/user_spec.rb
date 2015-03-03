require 'rails_helper'

describe "Users API", :type => :request do

	before { @user = FactoryGirl.create(:user) }

	# for /user/update-client, { :jive_id, :client }
	it "valid user updates a user's client " do
		post "/user/update-client", { jive_id: @user.jive_id, client: @user.client.name }
		expect(response).to be_success
		expect(json['status']).to eq(0)
		expect(json['message']).to eq("Client Updated")
	end

	it "should return that the user is not found" do 
		@user.jive_id = "ASDSADS"
		post "/user/update-client", { jive_id: @user.jive_id, client: @user.client }
		expect(response).to be_success
		expect(json['status']).to eq(1)
	end

	it "should return that there is no client by that name" do 
		post "/user/update-client", { jive_id: @user.jive_id, client: "blah" }
		expect(response).to be_success
		expect(json['status']).to eq(1)
		expect(json['error']).to eq("No client by name blah")
	end

	# for /user/check, { jive_id(as params[:user]) }
	it "should return success if user exists" do 
		get "/user/check", { user: @user.jive_id }
		expect(response).to be_success
		expect(json['status']).to eq(0)
		expect(json['client']['id']).to eq(@user.client.id)
		expect(json['user']['id']).to eq(@user.id)
		expect(json['user']['name']).not_to be_nil
		expect(json['client']['name']).not_to be_nil
	end

	it "should return status 1 if invalid jive_id" do 
		get "/user/check", { user: "asdasds" }
		expect(json['status']).to eq(1)
	end

	# for /user/create
	# Params: :jive_id, :employee_id, :name, :client(as client name)
	it "should create new user" do 	
		post "/user", { jive_id: 3432323, employee_id: "randomemplyee", name: "Test", client: "ww"}
		expect(response).to be_success
		expect(json['status']).to eq(0)
		expect(json['user']['jive_id']).not_to eq(@user.jive_id)
	end

	it "should respond with error (user needs jive_id and employee_id)" do 	
		post "/user", { employee_id: "randomemplyee", name: "Test", client: "ww"}
		expect(response).to be_success
		expect(json['status']).to eq(1)
		expect(json['error']).not_to be_nil
		post "/user", { jive_id: 234324, name: "Test", client: "ww"}
		expect(response).to be_success
		expect(json['status']).to eq(1)
		expect(json['error']).not_to be_nil
	end

	it "should update client if jive_id is valid" do 	
		post "/user", { jive_id: @user.jive_id, employee_id: @user.employee_id, name: @user.name, client: "ww"}
		expect(response).to be_success
		expect(json['status']).to eq(0)
		expect(json['user']['client_id']).not_to eq(@user.client_id)
		expect(json['user']['client_id']).to eq(Client.find_by(name: "ww").id)
	end

	it "should return same user/client if no client param" do 
		post "/user", { jive_id: @user.jive_id, employee_id: @user.employee_id, name: @user.name }
		expect(response).to be_success
		expect(json['status']).to eq(0)
		expect(json['user']['client_id']).to eq(@user.client_id)
	end

	# for /users
	# Params: :start, :count
	it "should return the right number of users and offset should work" do 
		get "/users", { count: 2, start: 0 }
		expect(response).to be_success
		expect(json['status']).to eq(0)
		expect(json['users'].length).to eq(2)		
	end

	it "should have a working offset" do 
		get "/users", { count: 4, start: 1 }
		expect(response).to be_success
		expect(json['status']).to eq(0)
		expect(json['users'].first['id']).not_to eq(User.first.id)
	end

	it "should have working defaults" do 
		get "/users"
		expect(response).to be_success
		expect(json['status']).to eq(0)
		expect(json['users'].count).to eq(50)
		expect(json['users'].first["id"]).to eq(User.first.id)
	end

	# for /users/search
	# Params: :term 
	it "should return valid results" do 
		get "/users/search", { term: "taylor" }
		expect(response).to be_success
		expect(json['status']).to eq(0)
		expect(json['users'].count).to be > 0
		expect(json['users'][0]['name'].include?("taylor"))
 	end

 	it "should ignore case" do 
 		get "/users/search", { term: "TAYLOR" }
		expect(response).to be_success
		expect(json['status']).to eq(0)
		expect(json['users'].count).to be > 0
		expect(json['users'][0]['name'].include?("TAYLOR".downcase))
 	end

 	it "should gracefully fail if no term is provided" do 
 		get "/users/search"
		expect(response).to be_success
		expect(json['status']).to eq(1)
 	end

 	# for /users/:jive (where :jive = jive_id)
 	it "should get retrieve proper user" do 
 		get "/users/#{@user.jive_id}"
 		expect(response).to be_success
		expect(json['status']).to eq(0)
		expect(json['user']['name']).to eq(@user.name)
 	end

 	it "should fail gracefully if user is not found" do 
 		get "/users/notaninteger"
 		expect(response).to be_success
		expect(json['status']).to eq(1)
 	end

end






