class ManagementController < ApplicationController
  load_and_authorize_resource :class => ManagementController
  
  def index

  end
  
  def approve_sellers
    @sellers = User.where("approved_seller = false AND roles.name = 'seller'").includes(:roles) 
    
    #if the view is being loaded via ajax, don't render the layout
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def user_search
    
    respond_to do |format|
      format.html {render :index}
      format.js { render :partial => "user_search", :layout => false }
    end
  end
  
  def user_search_results
    @users = User.search(params[:keywords], params[:role], params[:seller_approved], params[:seller_approval_style])
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def categories
    @categories = TopLevelCategory.all
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
    
  end
  
end
