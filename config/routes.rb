Rails.application.routes.draw do

  # disable registration, but allow for password change 
  # https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-password
  devise_for :admins, :skip => [:registrations]                                          
    as :admin do
      get 'admins/edit' => 'devise/registrations#edit', :as => 'edit_admin_registration'    
      put 'admins/:id' => 'devise/registrations#update', :as => 'admin_registration'            
    end
  get 'sessions/new'


  resources :update, only: [:create]

  
  # Content Routes
  resources :content, only: [:create]
  match "content/feature", to: "content#feature", via: :post
  match "content/attach-message", to: "content#attach_message", via: :post
  match "content/update-client", to: "content#update_client", via: :post
  match "content/get-message", to: "content#get_message", via: :get
  match "webhooks/content", to: "content#webhooks_content", via: :post
  match "test", to: "content#test", via: :get
  match "contents", to: "content#all", via: :get

  # Post Routes
  match "posts", to: "post#all", via: :get

  # User Routes
  match "/user/update-client", to: "user#update_client", via: :post     # tested
  match "/user/check", to: "user#check_init", via: :get                 # tested
  match "/user", to: "user#create", via: [:post, :options]              # tested 
  match "/users", to: "user#get_all", via: :get                         # tested        
  match "/users/search", to: "user#search", via: :get                   # tested
  match "/users/:jive", to: "user#get", via: :get                       # tested
  match "/user/new", to: "user#new", via: :get                          # non API <-------

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

  # CODE ROUTES
  match "code/request", to: "codes#new", via: [:options, :post]
  match "code/info", to: "codes#get_info", via: [:options, :post]
  match "code", to: "codes#get_code", via: [:options, :post]
  match "web/IE9/proxy.html", to: "codes#proxy", via: :get
  match "codes", to: "codes#get_all", via: :get
  match "codes/people", to: "codes#get_people", via: :get
  match "codes/load", to: "codes#load", via: [:post, :options]
  match "codes/toggle", to: "codes#toggle", via: [:post, :options]

  # MESSAGE ROUTES
  match "messages", to: "message#get_unread_messages", via: :get
  match "message/acknowledge", to: "message#acknowledge", via: [:post, :options]
  match "message", to: "message#send_message", via: [:post, :options]
  match "messages/all", to: "message#all", via: :get

  # ----- Begin Accessible Routes ------

  match "/cdc/upload/address-book", to: "accessible#upload_address_book", via: :get
  match "/cdc/process/address-book", to: "accessible#process_address_book_upload", via: :post
  match "/cdc/upload/a-to-z", to: "accessible#upload_a_to_z", via: :get
  match "/cdc/process/a-to-z", to: "accessible#process_a_to_z_upload", via: :post
  # A-Z
  match "/cdc/a-to-z", to: "accessible#edit_a_to_z", via: :get
  match "/cdc/a-to-z/search", to: "accessible#cdc_search", via: :get
  match "/cdc/a-to-z/get-range", to: "accessible#get_range", via: :get
  match "/cdc/a-to-z/topic", to: "accessible#get_topic", via: :get
  match "/cdc/change/a-to-z", to: "accessible#az_save_changes", via: :post
  # End A-Z Accessible

  # FX Deadlines and classifications
  match "/fx/deadlines/edit", to: "accessible#fx_edit_deadlines", via: :get
  match "/fx/deadline/save", to: "accessible#fx_save_deadline", via: :put
  match "/fx/upload/classifications", to: "accessible#upload_fx_classifications", via: :get
  match "/fx/process/classifications", to: "accessible#process_fx_classification_upload", via: :post
  match "/fx/upload/deadlines", to: "accessible#upload_deadlines", via: :get
  match "/fx/process/deadlines", to: "accessible#process_deadlines", via: :post
  match "/fx/deadlines/publication", to: "accessible#get_deadlines_by_pub", via: :get
  match "/fx/publications", to: "accessible#get_pubs", via: :get
  # End FX Dl and classifications
  match "/fx/request-article", to: "accessible#fx_request_article", via: :get
  match "/temp/upload", to: "accessible#temp_upload", via: :get
  match "/temp/upload/process", to: "accessible#temp_upload_process", via: :post
  # Maintainers
  match "/maintainers/all", to: "accessible#get_maintainers", via: :get
  match "/maintainers/:id/update", to: "accessible#update_maintainer", via: :post
  match "/maintainers/:id/toggle", to: "accessible#toggle_resolved", via: :post
  match "/maintainers", to: "accessible#maintainers", via: :get
  match "/admin/article-request/new", to: "accessible#new_article_request", via: [:post, :options]
  root to: "accessible#fx_request_article", via: :get

  # ----- End Accessible Routes ------

  # A-Z
  match "/cdc/api/search", to: "a_to_z#cdc_search", via: :get
  match "/cdc/api/get-range", to: "a_to_z#get_range", via: :get
  match "/cdc/api/topic", to: "a_to_z#get_topic", via: :get

  # ADDRESS BOOK
  match "cdc/address-book", to: "address_book#get_all", via: :get
  match "cdc/address-book/entry", to: "address_book#get_entry", via: :get

  # ----- Fairfax Routes ------  

  # FX DEADLINES
  match "fairfax/deadlines/publication", to: "deadline#get_deadlines_by_pub", via: :get
  match "fairfax/publications", to: "deadline#get_pubs", via: :get

  # FX CLASSIFICATION ROUTES
  match "fx/classifications", to: "fx_classification#get_classifications", via: :get  
  match "fx/classifications/categories", to: "fx_classification#get_categories", via: :get  

  # FX SUBURBS
  match "/fx/api/publications", to: "fx#get_all_publications", via: :get
  match "/fx/api/publications/:publication_id/suburbs", to: "fx#get_suburbs_for_publication", via: :get
  match "/fx/api/suburbs/:suburb_id/publications", to: "fx#get_publications_for_suburb", via: :get

  # ----- END Fairfax Routes ------  
  
  # TWITTER ROUTES
  match "tweets/multiple-users", to: "twitter#get_tweets_from_multiple", via: :get

  # SF Routes
  match "salesforce", to: "salesforce#test", via: :get
  match "salesforce/authenticate", to: "salesforce#authenticate", via: :get
  match 'auth/salesforce/callback', to: "salesforce#callback", via: :get
  match 'salesforce/auth/failure', to: "salesforce#failure", via: :get
  match 'salesforce/unauthenticate', to: "salesforce#unauthenticate", via: :get
  match 'salesforce/search/contact', to: "salesforce#search_for_contact", via: :get


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
