class SellerController < ApplicationController
  load_and_authorize_resource :class => InventoryItem
  
  def index
    user_id = current_user.id
    @current_inventory = InventoryItem.find_all_by_user_id(user_id)
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
    
  end
  
  def current_inventory
    user_id = current_user.id
    @current_inventory = InventoryItem.find_all_by_user_id(user_id)
    
    respond_to do |format|
      format.html { render "index" }
      format.js { render :partial => "inventory", :layout => false }
    end
    
  end
  
  def pick_list
    user_id = current_user.id
    @inventory_items = InventoryItem.joins(:cart_items)
                                    .where('inventory_items.user_id = ?', user_id)
                                    .select('inventory_items.*, sum(cart_items.quantity)')
                                    .group('inventory_items.id')
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
      format.pdf { render :layout => false }
    end
    
  end
  
end
