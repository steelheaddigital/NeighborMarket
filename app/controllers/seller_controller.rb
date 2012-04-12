class SellerController < ApplicationController
  load_and_authorize_resource
  
  def index
    
  end
  
  def current_inventory
    
    user_id = current_user.id
    @current_inventory = Inventory.find_all_by_user_id(user_id)
    
    respond_to do |format|
      format.js { render :layout => false }
    end
    
  end
  
end
