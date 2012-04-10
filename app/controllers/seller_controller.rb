class SellerController < ApplicationController
  load_and_authorize_resource
  
  def index
    
  end
  
  def current_inventory
    
    @current_inventory = Inventory.find_all_by_user_id(params[:user_id])
    
    respond_to do |format|
      format.js { render :layout => false }
    end
    
  end
  
end
