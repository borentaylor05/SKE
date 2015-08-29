Rails.application.routes.draw do

  # disable registration, but allow for password change 
  # https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-password
  devise_for :admins, :skip => [:registrations]                                          
    as :admin do
      get 'admins/edit' => 'devise/registrations#edit', :as => 'edit_admin_registration'    
      put 'admins/:id' => 'devise/registrations#update', :as => 'admin_registration'            
    end
  # get 'sessions/new'

  # devise_for :admins

  resources :update, only: [:create]
  
  # Content Routes
  resources :content, only: [:create]
  match "content/feature", to: "content#feature", via: :post
  match "content/attach-message", to: "content#attach_message", via: :post
  match "content/update-client", to: "content#update_client", via: [:post, :options]
  match "content/get-message", to: "content#get_message", via: :get
  match "webhooks/content", to: "content#webhooks_content", via: :post
  match "test", to: "content#test", via: :get
  match "contents", to: "content#all", via: :get

  # Post Routes
  match "posts", to: "post#all", via: :get

  # User Routes
  match "/user/update-client", to: "user#update_client", via: [:post, :options]     # tested
  match "/user/check", to: "user#check_init", via: :get                 # tested
  match "/user", to: "user#create", via: [:post, :options]              # tested 
  match "/users", to: "user#get_all", via: :get                         # tested        
  match "/users/search", to: "user#search", via: :get                   # tested
  match "/users/:jive", to: "user#get", via: :get                       # tested
  match "/user/new", to: "user#new", via: :get                          # non API <-------
  match "/user/:jive/check-pending", to: "user#check_pending", via: :get

  # Specialty Routes
  get "specialties/", to: "specialty#get"                                   # Not being used 
  match "user/add-specialties", to: "specialty#add_specialties", via: :post # Not being used 

  # Issue Routes
  match "issue/unresolve", to: "issue#unresolve", via: :post            # Not being used 
  match "issue/resolve", to: "issue#resolve", via: :post                # Not being used 
  match "webhooks/issue", to: "issue#webhook_create_issue", via: :post  # Not being used 

  #FFX Comments Routes
  match "/old/content", to: "old_content#check", via: [:post, :options]         # tested
  match "/old/comments", to: "old_comment#check", via: [:post, :options]        # tested
  match "/old/comment/toggle", to: "old_comment#toggle", via: [:post, :options] # tested

  # MESSAGE ROUTES
  match "/messages", to: "message#get_unread_messages", via: :get                 # tested     
  match "/message/acknowledge", to: "message#acknowledge", via: [:post, :options] # tested
  match "/message", to: "message#send_message", via: [:post, :options]            # tested
  match "/messages/all", to: "message#all", via: :get                             # tested

  # CLIENT ROUTES
  match "/api/clients/:client/lob-titles", to: "message#get_lobs_titles_for_client", via: :get

  # ----- Begin Accessible Routes ------

  match "/cdc", to: "accessible#cdc_home", via: :get
  match "/cdc/upload/address-book", to: "accessible#upload_address_book", via: :get
  match "/cdc/process/address-book", to: "accessible#process_address_book_upload", via: :post
  match "/cdc/upload/a-to-z", to: "accessible#upload_a_to_z", via: :get
  match "/cdc/process/a-to-z", to: "accessible#process_a_to_z_upload", via: :post
  # A-Z
  match "/cdc/a-to-z", to: "accessible#edit_a_to_z", via: :get
  match "/cdc/a-to-z/search", to: "accessible#cdc_search", via: :get
  match "/cdc/a-to-z/get-range", to: "accessible#get_range", via: :get
  match "/cdc/a-to-z/topic", to: "accessible#get_topic", via: :get
  match "/cdc/a-to-z/create", to: "accessible#new_a_to_z", via: :post
  match "/cdc/change/a-to-z", to: "accessible#az_save_changes", via: :post
  match "/cdc/apgs", to: 'accessible#cdc_view_apgs', via: :get
  match "/cdc/angular/apgs", to: 'accessible#cdc_get_apgs', via: :get # angular request route
  match "/cdc/apg/upload", to: 'accessible#cdc_upload_apg', via: :get
  match "/cdc/apg/process", to: 'accessible#cdc_process_apg', via: :post
  match "/cdc/apg/:id", to: 'accessible#cdc_delete_apg', via: :delete
  # End A-Z Accessible

  # FX Deadlines, classifications suburbs
  match "/fx/deadlines/edit", to: "accessible#fx_edit_deadlines", via: :get
  match "/fx/deadline/save", to: "accessible#fx_save_deadline", via: :put
  match "/fx/upload/classifications", to: "accessible#upload_fx_classifications", via: :get
  match "/fx/process/classifications", to: "accessible#process_fx_classification_upload", via: :post
  match "/fx/upload/deadlines", to: "accessible#upload_deadlines", via: :get
  match "/fx/process/deadlines", to: "accessible#process_deadlines", via: :post
  match "/fx/deadlines/publication", to: "accessible#get_deadlines_by_pub", via: :get
  match "/fx/publications", to: "accessible#get_pubs", via: :get
  match "/fx/suburbs", to: "accessible#fx_edit_suburbs", via: :get
  match "/fx/suburbs/condition", to: "accessible#get_suburbs_by_condition", via: :get
  match "/fx/upload/redelivery", to: "accessible#fx_upload_redelivery", via: :get
  match "/fx/process/redelivery", to: "accessible#process_fx_redelivery_upload", via: :post
  match "/fx/upload/pricing", to: "accessible#fx_upload_mag_pricing", via: :get
  match "/fx/process/pricing", to: "accessible#fx_upload_mag_pricing_process", via: :post
  # End FX Dl and classifications
  match "/fx/request-article", to: "accessible#fx_request_article", via: :get
  match "/temp/upload", to: "accessible#temp_upload", via: :get
  match "/temp/upload/db-only", to: "accessible#temp_upload_db_only", via: :get
  match "/temp/upload/process/db-only", to: "accessible#temp_upload_process_db_only", via: :post
  match "/temp/upload/process", to: "accessible#temp_upload_process", via: :post
  match "/temp/util/upload", to: "accessible#temp_util_upload", via: :get
  match "/temp/util/upload/process", to: "accessible#temp_util_upload_process", via: :post
  # Maintainers
  match "/maintainers/all", to: "accessible#get_maintainers", via: :get
  match "/maintainers/:id/update", to: "accessible#update_maintainer", via: :post
  match "/maintainers/:id/toggle", to: "accessible#toggle_resolved", via: :post
  match "/maintainers", to: "accessible#maintainers", via: :get
  match "/admin/article-request/new", to: "accessible#new_article_request", via: [:post, :options]

  root to: "accessible#fx_request_article", via: :get

  match "/gamification/mission/new", to: "accessible#gamification", via: :get
  match "/gamification/mission", to: "accessible#get_mission", via: :get
  match "/gamification/:client/missions", to: "accessible#get_missions", via: :get
  match "/gamification/mission/create", to: "accessible#create_mission", via: :post
  match "/gamification/:client/upload", to: "accessible#game_data_upload", via: :get
  match "/gamification/:client/edit", to: "accessible#prioritize_missions", via: :get
  match "/gamification/:client/edit", to: "accessible#prioritize_missions", via: :post
  match "/gamification/upload/:client", to: "accessible#gamification_upload", via: :get
  match "/gamification/upload/:client/process", to: "accessible#gamification_upload_process", via: :post

  match "/clients/:client/lob-titles", to: "accessible#get_lobs_titles_for_client", via: :get
  match "/clients", to: "accessible#get_clients", via: :get

  match "ske/users", to: "accessible#users", via: :get
  match "/ske/users/bulk-upload", to: "accessible#bulk_upload_users", via: :get
  match "/ske/users/bulk-upload/process", to: "accessible#bulk_upload_users_process", via: :post


  # USERS 

  match "/ske/user/new", to: "accessible#new_user", via: :get
  match "/ske/user", to: "accessible#create_user", via: :post
  match "/ske/admin/new", to: "accessible#new_admin", via: :get
  match "/ske/admin", to: "accessible#create_admin", via: :post

  match "/admins", to: "accessible#admins_home", via: :get

  # ----- End Accessible Routes ------

  # ----- CDC Routes ------  

  # A-Z
  match "/cdc/api/search", to: "a_to_z#cdc_search", via: :get     # tested
  match "/cdc/api/get-range", to: "a_to_z#get_range", via: :get   # tested
  match "/cdc/api/topic", to: "a_to_z#get_topic", via: :get       # tested

  # ADDRESS BOOK
  match "cdc/address-book", to: "address_book#get_all", via: :get         # 
  match "cdc/address-book/entry", to: "address_book#get_entry", via: :get

  # HRSA APG ROUTES -- screwed up name of models and controllers (should be hrsa not CDC)
  match "/hrsa/api/apg/documents/:id", to: "cdc#apg_init", via: :get
  match "/hrsa/api/apg/topics/:id", to: 'cdc#get_topic', via: :get
  match "/hrsa/api/apg/categories/:id", to: 'cdc#get_category', via: :get

  # ----- End CDC Routes ------  

  # ----- Fairfax Routes ------  

  # FX DEADLINES
  match "fairfax/deadlines/publication", to: "deadline#get_deadlines_by_pub", via: :get
  match "fairfax/publications", to: "deadline#get_pubs", via: :get

  # FX CLASSIFICATION ROUTES
  match "fx/classifications", to: "fx_classification#get_classifications", via: :get  
  match "fx/classifications/categories", to: "fx_classification#get_categories", via: :get  

  #FX PUBLICATIONS
  match "/fx/api/publications", to: "fx#get_all_publications", via: :get
  match "/fx/api/publication/:publication_id", to: "fx#get_publication", via: :get
  match "/fx/api/publications/:publication_id/suburbs", to: "fx#get_suburbs_for_publication", via: :get
  match "/fx/api/publications/:publication_id/pricing", to: "fx#get_publication_pricing", via: :get
  
  # FX SUBURBS
  match "/fx/api/suburbs/:suburb_id/publications", to: "fx#get_publications_for_suburb", via: :get
  match "/fx/api/suburbs/search", to: "fx#suburb_search", via: :get

  # COST PER THOUSANDS
  match "/fx/api/publications/:publication_id/cost-per-thousands", to: "fx#cpts_for_publication", via: :get  

  # REDELIVERY
  match "/fx/api/redelivery/publications", to: "fx#red_publications", via: :get  
  match "/fx/api/publication/:id/redeliveries", to: "fx#get_pub_redeliveries", via: :get
  match "/fx/api/redelivery/:id", to: "fx#get_redelivery", via: :get
  match "/fx/api/search/redeliveries", to: "fx#redelivery_search", via: :get

  # CODE-RATES
  match "/fx/api/code-rates", to: "fx#get_code_rates", via: :get

  # NEWS AGENT
  match "/fx/api/newsagent", to: "fx#get_news_agent", via: :get

  # ----- END Fairfax Routes ------ 

  # ----- BEGIN WW Routes ------ 

  # CODE ROUTES
  match "code/request", to: "codes#new", via: [:options, :post]
  match "code/info", to: "codes#get_info", via: [:options, :post]
  match "code", to: "codes#get_code", via: [:options, :post]
  match "web/IE9/proxy.html", to: "codes#proxy", via: :get
  match "codes", to: "codes#get_all", via: :get
  match "codes/people", to: "codes#get_people", via: :get
  match "codes/load", to: "codes#load", via: [:post, :options]
  match "codes/toggle", to: "codes#toggle", via: [:post, :options] 

  # PROMO ROUTES
  match "/ww/api/promotions", to: "ww#create_promotion_entry", via: [:post, :options]   #tested

  # ----- END WW Routes ------ 

  # ----- Begin ARC Routes ------ 

  match "/arc/api/rco", to: "arc#create_rco", via: [:post, :options]
  match "/arc/api/rcos", to: "arc#get_rcos", via: :get
  match "/arc/api/blackout-dates", to: "arc#create_blackout_dates", via: [:post, :options]
  match "/arc/api/blackout-dates/check", to: "arc#check_cities", via: [:post, :options]
  match "/arc/api/blackout-dates/:city/:state", to: "arc#get_blackout_dates", via: :get
  match "/arc/api/blackout-dates/group", to: "arc#get_groups", via: :get
  match "/arc/api/blackout-dates/group", to: "arc#new_group", via: [:post, :options]
  match "/arc/api/cities", to: "arc#get_all_cities", via: :get
  match "/arc/api/checks", to: "arc#create_check", via: [:post, :options]
  match "/arc/api/checks/:check_id", to: "arc#update_check", via: [:post, :options]
  match "/arc/api/checks", to: "arc#get_checks", via: :get
  match "/arc/api/checks/agents", to: "arc#get_check_agents", via: :get

  # ----- End ARC Routes ------ 
  
  # TWITTER ROUTES
  match "tweets/multiple-users", to: "twitter#get_tweets_from_multiple", via: :get

  # SF Routes
  match "salesforce", to: "salesforce#test", via: :get
  match "salesforce/authenticate", to: "salesforce#authenticate", via: :get
  match 'auth/salesforce/callback', to: "salesforce#callback", via: :get
  match 'salesforce/auth/failure', to: "salesforce#failure", via: :get
  match 'salesforce/unauthenticate', to: "salesforce#unauthenticate", via: :get
  match 'salesforce/search/contact', to: "salesforce#search_for_contact", via: :get

  # GAMIFICATION ROUTES
  match '/api/gamification/leaderboard', to: "gamification#leaderboard", via: :get
  match '/api/gamification/missions', to: "gamification#missions", via: :get
  match '/api/gamification/:jive_id/top-three', to: "gamification#top_three", via: :get
  match '/api/gamification/missions/users/:username', to: "gamification#user_missions", via: :get

  # S3 Upload Route
  match "/s3-upload", to: "content#generate_s3_json", via: :get

  # Maintainer routes
  match "/maintainers/comment/new", to: "maintainers#new_comment_maintainer", via: [:options, :post]
  match "/maintainers/article-request/new", to: "maintainers#new_article_request", via: [:post, :options]


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
