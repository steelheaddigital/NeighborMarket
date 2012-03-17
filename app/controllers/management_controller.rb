class ManagementController < ApplicationController
  load_and_authorize_resource :class => ManagementController
  
  def index
    
  end
  
  def approve_sellers
    @sellers = Seller.find_all_by_approved(false)
    
    #if the view is being loaded via ajax, don't render the layout
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def user_search    
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def user_search_results
    @users = User.search(params[:keywords], params[:role], params[:seller_approved], params[:seller_approval_style])
    
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
end
