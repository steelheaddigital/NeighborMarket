class ManagementController < ApplicationController
  load_and_authorize_resource :class => ManagementController
  
  def index
    
  end
  
  def approve_sellers
    @sellers = Seller.find_all_by_approved(false)
  end
end
