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
  
  resources :management, :only => ["index"] do
    collection do
      get 'approve_sellers'
      get 'user_search'
      get 'user_search_results'
      get 'categories'
      get 'inbound_delivery_log'
      post 'save_inbound_delivery_log'
      get 'outbound_delivery_log'
      post 'save_outbound_delivery_log'
      get 'buyer_invoices'
      get 'order_cycle'
      post 'update_order_cycle'
      get 'site_setting'
      post 'update_site_setting'
    end
  end
  
  resources :inventory_items do
    collection do
      get 'get_second_level_category'
      get 'search'
      get 'browse'
      get 'browse_all'
    end
  end
  
  match 'seller/:cart_item_id/remove_item_from_order' => 'seller#remove_item_from_order', :via => "DELETE", :as => :seller_remove_item_from_order
  match 'seller/:order_id/update_order' => 'seller#update_order', :via => "PUT", :as => :seller_update_order
  resources :seller, :only => ["index"] do
    collection do
      get 'current_inventory'
      get 'pick_list'
      get 'packing_list'
      post 'previous_packing_list'
      post 'previous_pick_list'
    end
  end
  
  resources :top_level_categories 
  
  resources :second_level_categories
  
  resources :cart_items, :only => ["create"] do
    get 'destroy'
  end
  
  resources :cart, :only => ["index"] do
    collection do
      get 'item_count'
    end
  end
  
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
