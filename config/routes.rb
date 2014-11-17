NeighborMarket::Application.routes.draw do

  get "home/index"
  get "home/refresh"
  get "home/user_home"
  get "home/paginate_items"
  
  root :to => "home#index"
  devise_for :users, :controllers => { :registrations => 'user_registrations', :sessions => 'sessions', :confirmations => 'user_confirmations' }
  devise_scope :user do 
    match '/buyer/sign_up' => 'user_registrations#new', :user => { :user_type => 'buyer' }, :as => :buyer_sign_up, via: [:get, :post]
    match '/seller/sign_up' => 'user_registrations#new', :user => { :user_type => 'seller' }, :as => :seller_sign_up, via: [:get, :post]
    match '/user/become_seller' => 'user_registrations#become_seller', :user => { :become_seller => true } , :as => :become_seller, via: [:get, :post]
    match '/user/become_buyer' => 'user_registrations#become_buyer', :user => { :become_buyer => true }, :as => :become_buyer, via: [:get, :post]
    match '/user/seller_inactive_signup' => 'user_registrations#seller_inactive_signup', via: [:get, :post]
    match '/user/inactive_signup' => 'user_registrations#inactive_signup', via: [:get, :post]
    get '/user/auto_create_confirmation', to: 'user_confirmations#auto_create_confirmation'
    match '/user_registrations/terms_of_service', via: [:get, :post]
  end
  
  resources :user do 
    member do
      post "approve_seller"
    end
    collection do
      post "import"
      get "upload_error_file"
    end
  end
  
  resources :management do
    collection do
      get 'edit_site_settings'
      post 'update_site_settings'
      get 'edit_order_cycle_settings'
      post 'update_order_cycle_settings'
      get 'approve_sellers'
      get 'user_search'
      get 'user_search_results'
      get 'categories'
      get 'inbound_delivery_log'
      post 'save_inbound_delivery_log'
      get 'outbound_delivery_log'
      post 'save_outbound_delivery_log'
      get 'buyer_invoices'
      get 'site_setting'
      post 'update_site_setting'
      get 'inventory_item_approval'
      post 'update_inventory_item_approval'
      get 'inventory'
      get 'edit_inventory'
      get 'historical_orders'
      post 'historical_orders_report'
      get 'add_users'
      get 'new_users_report'
      get 'updated_user_profile_report'
      get 'deleted_users_report'
      get 'manage_units'
      post 'create_price_unit'
      delete 'destroy_price_unit'
      get 'inventory_item_change_requests'
      get 'order_change_requests'
      post 'test_email'
    end
  end
  
  resources :inventory_items do
    member do
      post 'delete_from_current_inventory'
      get 'change_request'
      post 'send_change_request'
      post 'review'
    end
    collection do
      get 'get_second_level_category'
      get 'search'
      get 'browse'
      get 'browse_all'
      get 'units'
      get 'user_reviews'
    end
  end
  
  put 'seller/:order_id/update_order', to: 'seller#update_order', :as => :seller_update_order
  resources :seller, :only => ["index"] do
    collection do
      get 'pick_list'
      get 'packing_list'
      get 'sales_report'
      get 'reviews'
      post 'sales_report_details'
      post 'add_past_inventory'
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
  
  post 'orders/new', to: 'orders#new'
  resources :orders, :only => ["create", "edit", "update", "show", "destroy"] do
    member do
      get 'finish'
    end
  end
  
  resources :price_units
  
  get 'inventory_item_change_request/:inventory_item_id/new', to: 'inventory_item_change_request#new', :as => :new_inventory_item_change_request
  get 'inventory_item_change_request/:inventory_item_id/create', to: 'inventory_item_change_request#create', :as => :create_inventory_item_change_request
  resources :inventory_item_change_request do
    member do
      post 'complete'
    end
  end
  
  get 'order_change_request/:order_id/new', to: 'order_change_request#new', :as => :new_order_change_request
  post 'order_change_request/:order_id/create', to: 'order_change_request#create', :as => :create_order_change_request
  resources :order_change_request do
    member do
      post 'complete'
    end
  end
  
  resources :reviews
  
  get 'user_contact_messages/:id', to: 'user_contact_messages#new', as: 'new_user_contact_message'
  post 'user_contact_messages/:id', to: 'user_contact_messages#create', as: 'create_user_contact_message'
  
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
