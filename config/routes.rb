GardenMarketplace::Application.routes.draw do
  get "home/index"
  root :to => "home#index"
  devise_for :users, :controllers => { :registrations => 'UserRegistrations' }
  devise_scope :user do 
    match 'buyer/sign_up' => 'user_registrations#new', :user => { :user_type => 'buyer' }, :as => :buyer_sign_up
    match 'seller/sign_up' => 'user_registrations#new', :user => { :user_type => 'seller' }, :as => :seller_sign_up
    match 'become_seller' => 'user_registrations#become_seller', :become_seller => true , :as => :become_seller
    match 'users/inactive_signup' => 'user_registrations#inactive_signup'
  end
  
  resources :users do 
    member do
      post "approve_seller"
      get "show_public"
    end
  end
  
  match 'management/approve_sellers' => 'management#approve_sellers'
  match 'management/user_search' => 'management#user_search'
  match 'management/user_search_results' => 'management#user_search_results'
  match 'management/categories' => 'management#categories'
  resources :management, :only => ["index"]
  
  match 'inventory_items/get_second_level_category' => 'inventory_items#get_second_level_category'
  match 'inventory_items/search' => 'inventory_items#search'
  resources :inventory_items
  
  match "seller/current_inventory" => "seller#current_inventory"
  resources :seller, :only => ["index"]
  
  resources :top_level_categories 
  
  resources :second_level_categories 
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
