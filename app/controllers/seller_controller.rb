class SellerController < ApplicationController
  load_and_authorize_resource
  
  def index
    user_id = current_user.id
    @current_inventory = InventoryItem.find_all_by_user_id(user_id)
    
    respond_to do |format|
      format.html
    end
    
  end
  
  def current_inventory
    
    user_id = current_user.id
    @current_inventory = InventoryItem.find_all_by_user_id(user_id)
    
    respond_to do |format|
      format.html {render "index"}
      format.js { render :partial => "inventory", :layout => false }
    end
    
  end
  
end
