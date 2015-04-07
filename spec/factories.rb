FactoryGirl.define do  factory :user_mission do
    user_id 1
mission_id 1
  end
  factory :jive_mission do
    
  end
  factory :empower_mission do
    metric_name "MyString"
target "MyString"
  end
  factory :mission do
    bunchball_name "MyString"
    badge_url "MyString"
    game_type "MyString"
    game_id 1
    folder "MyString"
  end
  factory :ww_promotion do
      member_num "MyString"
      first_name "MyString"
      last_name "MyString"
      gender "M"
      billing "MyString"
      city "MyString"
      state "MyString"
      zip 1
      agent_name "MyString"
  end

  factory :redelivery do
      fx_publication_id 1
      town "MyString"
      round_id "MyString"
      redelivery false
      cutoff_mf "MyString"
      cutoff_sat "MyString"
      cutoff_sun "MyString"
  end

  factory :cost_per_thousand do
    publications "MyString"
    cost 1
  end
  
  factory :fx_publications_suburb do
    fx_publication_id 1
    suburb_id 1
  end

  factory :fx_publication do
    name "A Publication"
    parent "A Parent Publication"
  end
  
  factory :suburb do
    name "A suburb"
  end

  factory :user do
    jive_id User.first.jive_id
    employee_id User.first.employee_id
    client User.first.client
    name User.first.name
    lob "Consulting"
    location "Denver"
    title "Developer"
  end

  factory :old_content do 
  	api_id OldContent.first.api_id
  	comments 1
  	link 'http://localhost:8080/docs/DOC-1033'
  	commentsUrl 'http://localhost:8080/api/core/v3/contents/1046/comments'
  	title 'Bergdorf Goodman'
  end

  factory :old_comment do 
  	old_content_id OldContent.first.api_id
    api_id OldComment.first.api_id
    resolved false
  end


end