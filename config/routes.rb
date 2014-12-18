Rails.application.routes.draw do

  resources :user, only: [:create]

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

  # Specialty Routes
  get "specialties/", to: "specialty#get"
  match "user/add-specialties", to: "specialty#add_specialties", via: :post

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
