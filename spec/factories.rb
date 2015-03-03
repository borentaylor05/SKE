FactoryGirl.define do
  factory :user do
    jive_id User.first.jive_id
    employee_id User.first.employee_id
    client User.first.client
    name User.first.name
    lob "Consulting"
    location "Denver"
    title "Developer"
  end
end