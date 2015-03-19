FactoryGirl.define do  factory :cost_per_thousand do
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