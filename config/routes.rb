NeighborMarket::Application.routes.draw do

  get "home/index"
  root :to => "home#index"
  devise_for :users, :controllers => { :registrations => 'user_registrations', :sessions => 'sessions' }
  devise_scope :user do 
    match '/buyer/sign_up' => 'user_registrations#new', :user => { :user_type => 'buyer' }, :as => :buyer_sign_up
    match '/seller/sign_up' => 'user_registrations#new', :user => { :user_type => 'seller' }, :as => :seller_sign_up
    match '/user/become_seller' => 'user_registrations#become_seller', :user => { :become_seller => true } , :as => :become_seller
    match '/user/become_buyer' => 'user_registrations#become_buyer', :user => { :become_buyer => true } , :as => :become_buyer
    match '/user/inactive_signup' => 'user_registrations#inactive_signup'
  end
  
  resources :users do 
    member do
      post "approve_seller"
      post "contact"
      get "public_show"
    end
  end
  
  match 'management/approve_sellers' => 'management#approve_sellers'
  match 'management/user_search' => 'management#user_search'
  match 'management/user_search_results' => 'management#user_search_results'
  match 'management/categories' => 'management#categories'
  match 'management/inbound_delivery_log' => 'management#inbound_delivery_log'
  match 'management/save_inbound_delivery_log' => 'management#save_inbound_delivery_log', :via => "POST"
  match 'management/outbound_delivery_log' => 'management#outbound_delivery_log'
  match 'management/save_outbound_delivery_log' => 'management#save_outbound_delivery_log', :via => "POST"
  match 'management/buyer_invoices' => 'management#buyer_invoices'
  match 'management/order_cycle' => 'management#order_cycle'
  match 'management/update_order_cycle' => 'management#update_order_cycle', :via => "POST"
  match 'management/site_setting' => 'management#site_setting'
  match 'management/update_site_setting' => 'management#update_site_setting', :via => "POST"
  resources :management, :only => ["index"]
  
  match 'inventory_items/get_second_level_category' => 'inventory_items#get_second_level_category'
  match 'inventory_items/search' => 'inventory_items#search'
  match 'inventory_items/browse' => 'inventory_items#browse'
  match 'inventory_items/browse_all' => 'inventory_items#browse_all'
  resources :inventory_items
  
  match 'seller/current_inventory' => 'seller#current_inventory'
  match 'seller/pick_list' => 'seller#pick_list'
  match 'seller/packing_list' => 'seller#packing_list'
  resources :seller, :only => ["index"]
  
  resources :top_level_categories 
  
  resources :second_level_categories
  
  resources :cart_items, :only => ["create"] do
    get 'destroy'
  end
  
  match 'cart/item_count' => 'cart#item_count'
  resources :cart, :only => ["index"]
  
  match 'orders/new' => 'orders#new', :via => "POST"
  resources :orders, :only => ["create", "edit", "update", "show", "destroy"]
  
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
