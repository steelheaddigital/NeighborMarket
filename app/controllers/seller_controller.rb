class SellerController < ApplicationController
  load_and_authorize_resource :class => InventoryItem
  skip_authorize_resource :only => :contact
  
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
    current_cycle_id = OrderCycle.current_cycle_id
    @inventory_items = InventoryItem.joins(:cart_items => :order)
                                    .where('inventory_items.user_id = ? AND orders.order_cycle_id = ?', user_id, current_cycle_id)
                                    .select('inventory_items.id, inventory_items.name, inventory_items.price_unit, sum(cart_items.quantity)')
                                    .group('inventory_items.id, inventory_items.name, inventory_items.price_unit')
    respond_to do |format|
      format.html
      format.js { render :layout => false }
      format.pdf { render :layout => false }
    end
    
  end
  
  def packing_list
    user_id = current_user.id
    current_cycle_id = OrderCycle.current_cycle_id
    @orders = Order.joins(:cart_items => :inventory_item)
                   .select('orders.id, orders.user_id')
                   .where(:inventory_items => {:user_id => user_id}, :orders => {:order_cycle_id => current_cycle_id})
                   .group('orders.id, orders.user_id')
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
      format.pdf { render :layout => false }
    end
  end
  
end
