Rails.application.routes.draw do

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
  match "user/update-client", to: "user#update_client", via: :post
  match "user/check", to: "user#check_init", via: :get
  match "user", to: "user#create", via: [:post, :options]
  match "users", to: "user#get_all", via: :get
  match "users/search", to: "user#search", via: :get

  # Specialty Routes
  get "specialties/", to: "specialty#get"
  match "user/add-specialties", to: "specialty#add_specialties", via: :post

  # Issue Routes
  match "issue/unresolve", to: "issue#unresolve", via: :post
  match "issue/resolve", to: "issue#resolve", via: :post
  match "webhooks/issue", to: "issue#webhook_create_issue", via: :post

  # Request Routes
  match "request/new-content", to: "content_request#new_content", via: [:post, :options]
  match "request/revision", to: "content_request#revision", via: :post
  match "requests", to: "content_request#all", via: :get

  #FFX Comments Routes
  match "old/content", to: "old_content#check", via: [:post, :options]
  match "old/comments", to: "old_comment#check", via: [:post, :options]
  match "old/comment/toggle", to: "old_comment#toggle", via: [:post, :options]

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

  # ACCESSIBLE ROUTES
  match "cdc/verify", to: "accessible#verify", via: :post
  match "cdc/upload/address-book", to: "accessible#upload_address_book", via: :get
  match "cdc/process/address-book", to: "accessible#process_address_book_upload", via: :post
  match "cdc/upload/a-to-z", to: "accessible#upload_a_to_z", via: :get
  match "cdc/process/a-to-z", to: "accessible#process_a_to_z_upload", via: :post
  match "cdc/a-to-z", to: "accessible#edit_a_to_z", via: :get
  match "cdc/change/a-to-z", to: "accessible#az_save_changes", via: :post
  match "authenticate", to: "accessible#authenticate", via: :get
  match "verify", to: "accessible#verify_user", via: :post
  match "fx/deadlines/edit", to: "accessible#fx_edit_deadlines", via: :get
  match "fx/deadline/save", to: "accessible#fx_save_deadline", via: :put
  match "fx/upload/classifications", to: "accessible#upload_fx_classifications", via: :get
  match "fx/process/classifications", to: "accessible#process_fx_classification_upload", via: :post
  match "fx/upload/deadlines", to: "accessible#upload_deadlines", via: :get
  match "fx/process/deadlines", to: "accessible#process_deadlines", via: :post

  # A-Z
  match "cdc/api/search", to: "a_to_z#cdc_search", via: :get
  match "cdc/api/get-range", to: "a_to_z#get_range", via: :get
  match "cdc/api/topic", to: "a_to_z#get_topic", via: :get

  # ADDRESS BOOK
  match "cdc/address-book", to: "address_book#get_all", via: :get
  match "cdc/address-book/entry", to: "address_book#get_entry", via: :get

  # FX DEADLINES
  match "fairfax/deadlines/publication", to: "deadline#get_deadlines_by_pub", via: :get
  match "fairfax/publications", to: "deadline#get_pubs", via: :get

  # FX CLASSIFICATION ROUTES
  match "fx/classifications", to: "fx_classification#get_classifications", via: :get  
  match "fx/classifications/categories", to: "fx_classification#get_categories", via: :get  
  
  # TWITTER ROUTES

  match "tweets/multiple-users", to: "twitter#get_tweets_from_multiple", via: :get



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
