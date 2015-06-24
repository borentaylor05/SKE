FactoryGirl.define do  factory :fx_news_agent do
    code "MyString"
agent "MyString"
fax_email "MyString"
  end
  factory :fx_code_rate do
    schedule "MyString"
month_code "MyString"
month_rate "9.99"
year_code "MyString"
year_rate "9.99"
other "MyString"
three_day false
  end
  factory :fx_codes_rate do
    schedule "MyString"
month_code "MyString"
month_rate 1
year_code "MyString"
year_rate 1
other "MyString"
three_day false
  end
  factory :state do
    name "MyString"
abbreviation "MyString"
  end
  factory :arc_blackout_tracker do
    arc_blackout_date_id 1
arc_city_state_id 1
  end
  factory :arc_blackout_date do
    date "MyString"
notes "MyString"
  end
  factory :arc_city_state do
    city "MyString"
state "MyString"
  end
  factory :rco_order do
    agent_name "MyString"
created false
acct_with_password false
acct_forgot_password false
no_share false
order_id "MyString"
lms_num 1
num_registrations 1
coupon "MyString"
paypal false
knows_lms false
need_dir false
attch_sent false
comments "MyText"
  end
  factory :fx_mag_pricing do
    six_month "MyString"
    one_year_renewal "MyString"
    one_year_new "MyString"
    two_year_new "MyString"
    two_year_renewal "MyString"
    one_year_supergold "MyString"
    three_year_new "MyString"
    three_year_renewal "MyString"
  end

  factory :user_mission do
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
    bunchball_name "sads"
    badge_url "dfgdfg"
    game_type "EmpowerMission"
    game_id 1
    folder "vbcb"
  end
  
  factory :ww_promotion do
      member_num Random.new(1234).rand(100000)
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
    jive_id Random.new(1234).rand(100000)
    employee_id Random.new(14).rand(100000)
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