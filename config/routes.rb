NeighborMarket::Application.routes.draw do
  
  root :to => "home#index"
  
  devise_for :users, :controllers => { :registrations => 'user_registrations', :sessions => 'sessions', :confirmations => 'user_confirmations' }
  devise_scope :user do 
    match '/buyer/sign_up' => 'user_registrations#new', :user => { :user_type => 'buyer' }, :as => :buyer_sign_up, via: [:get, :post]
    match '/seller/sign_up' => 'user_registrations#new', :user => { :user_type => 'seller' }, :as => :seller_sign_up, via: [:get, :post]
    match '/user/become_seller' => 'user_registrations#become_seller', :user => { :become_seller => true } , :as => :become_seller, via: [:get, :post]
    match '/user/seller_inactive_signup' => 'user_registrations#seller_inactive_signup', via: [:get, :post]
    match '/user/inactive_signup' => 'user_registrations#inactive_signup', via: [:get, :post]
    get '/user/auto_create_confirmation', to: 'user_confirmations#auto_create_confirmation'
    match '/user_registrations/terms_of_service', via: [:get, :post]
  end
  
  get "sitemap.xml", to: "home#sitemap", defaults: { format: :xml }, as: :sitemap
  get "robots.txt", to: "home#robots", defaults: { format: :text }, as: :robots
  get "home/index"
  get "home/user_home"
  get "home/paginate_items"
  
  get 'sellers', to: 'user#index', as: 'sellers'
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
      post 'test_email'
    end
  end
  
  resources :site_settings, :only => ["index"] do
    collection do
      post 'update', as: 'update'
    end
  end
  
  resources :site_contents, :only => ["index"] do 
    collection do
      post 'update', as: 'update'
    end
  end

  resources :payment_processor_settings, :only => ["index"] do 
    collection do
      post 'update', as: 'update'
    end
  end
  
  resources :user_payment_settings, only: ['index']

  resources :user_in_person_settings, only: ['update']
  
  resources :user_paypal_express_settings, only: ['create', 'update'] do
    collection do
      get 'grant_permissions'
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
      get 'browse_all'
      get 'units'
      get 'user_reviews'
    end
  end
  
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
  
  post 'cart/checkout', to: 'cart#checkout', as: 'checkout'
  resources :cart, :only => ["index"] do
    collection do
      get 'item_count'
    end
  end
  
  get  'orders/finish', to: 'orders#finish', as: 'finish_order'
  get  'orders/complete_update', to: 'orders#complete_update', as: 'complete_update_order'
  resources :orders
  
  resources :price_units
  
  get 'inventory_item_change_requests/:inventory_item_id/new', to: 'inventory_item_change_requests#new', :as => :new_inventory_item_change_request
  get 'inventory_item_change_requests/:inventory_item_id/create', to: 'inventory_item_change_requests#create', :as => :create_inventory_item_change_request
  resources :inventory_item_change_requests, only: ['index'] do
    member do
      post 'complete'
    end
  end
  
  get 'order_change_requests/:order_id/new', to: 'order_change_requests#new', :as => :new_order_change_request
  post 'order_change_requests/:order_id/create', to: 'order_change_requests#create', :as => :create_order_change_request
  resources :order_change_requests, only: ['index'] do
    member do
      post 'complete'
    end
  end
  
  resources :reviews
  
  get 'user_contact_messages/:id', to: 'user_contact_messages#new', as: 'new_user_contact_message'
  post 'user_contact_messages/:id', to: 'user_contact_messages#create', as: 'create_user_contact_message'
  
  get 'info/about', to: 'info#about'
  get 'info/terms', to: 'info#terms'
  get 'info/privacy', to: 'info#privacy'

  post 'contact', to: 'contact#create'
  resources :contact, :only => ["index"]

  post 'payments/confirm', to: 'payments#confirm', as: :payments_confirm

  resources :user_preferences, only: ['update', 'edit']

  resources :payments, only: ['destroy']
end
