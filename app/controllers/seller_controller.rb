class SellerController < ApplicationController
  load_and_authorize_resource :class => InventoryItem
  skip_authorize_resource :only => :contact
  
  def index
    last_order_cycle_date = OrderCycle.where(:status => "complete")
                                      .maximum(:end_date)
    order_cycle = OrderCycle.where(:end_date => last_order_cycle_date).last()
    order_cycle_id = order_cycle ? order_cycle.id : 0
    @last_inventory = get_last_inventory(order_cycle_id)
    @current_inventory = get_current_inventory
    @previous_order_cycles = OrderCycle.last_ten_cycles
    @selected_previous_order_cycle = @previous_order_cycles.find{|e| e.id = order_cycle_id}
    @show_past_inventory_container = ""
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def previous_index
    order_cycle = OrderCycle.find(params[:selected_previous_order_cycle][:id])
    order_cycle_id = order_cycle ? order_cycle.id : 0
    @last_inventory = get_last_inventory(order_cycle_id)
    @current_inventory = get_current_inventory
    @previous_order_cycles = OrderCycle.last_ten_cycles
    @selected_previous_order_cycle = @previous_order_cycles.find{|e| e.id = order_cycle_id}
    @show_past_inventory_container = "in"
    
    respond_to do |format|
      format.html {render :index }
      format.js { render :index, :layout => false }
    end
  end
  
  def add_past_inventory
    items = params[:item]
    items.each do |item|
      inventory_item = InventoryItem.find(item[1])
      inventory_item.copy_to_new_cycle
    end
    
    respond_to do |format|
      format.html { redirect_to seller_index_path, notice: 'Items successfully added!' }
      format.js { render :partial => "inventory", :layout => false }
    end
  end
  
  def pick_list
    order_cycle = OrderCycle.latest_cycle
    order_cycle_id = order_cycle ? order_cycle.id : 0
    @inventory_items = get_pick_list_inventory_items(order_cycle_id)
    @previous_order_cycles = OrderCycle.last_ten_cycles
    @selected_previous_order_cycle = @previous_order_cycles.find{|e| e.id = order_cycle_id}
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def previous_pick_list
    order_cycle_id = params[:selected_previous_order_cycle][:id]
    @inventory_items = get_pick_list_inventory_items(order_cycle_id)
    @previous_order_cycles = OrderCycle.last_ten_cycles
    @selected_previous_order_cycle = @previous_order_cycles.find{|e| e.id = order_cycle_id}
    
    respond_to do |format|
      format.html{render :pick_list}
      format.js { render :pick_list, :layout => false }
      format.pdf { render :pick_list, :layout => false }
    end
  end
  
  def packing_list
    order_cycle = OrderCycle.latest_cycle
    order_cycle_id = order_cycle ? order_cycle.id : 0
    @seller = current_user
    @orders = get_packing_list_orders(order_cycle_id)
    @previous_order_cycles = OrderCycle.last_ten_cycles
    @selected_previous_order_cycle = @previous_order_cycles.last
    @can_edit = order_cycle.status == "current"
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def previous_packing_list
    order_cycle = OrderCycle.find(params[:selected_previous_order_cycle][:id])
    order_cycle_id = order_cycle ? order_cycle.id : 0
    @seller = current_user
    @orders = get_packing_list_orders(order_cycle_id)
    @previous_order_cycles = OrderCycle.last_ten_cycles
    @selected_previous_order_cycle = @previous_order_cycles.find{|e| e.id = order_cycle_id}
    @can_edit = order_cycle.status == "current"
    
    respond_to do |format|
      format.html{ render :packing_list}
      format.js { render :packing_list, :layout => false }
      format.pdf { render :packing_list, :layout => false }
    end
  end
  
  def remove_item_from_order
    cart_item = CartItem.find(params[:cart_item_id])
    @orders = get_packing_list_orders(cart_item.order.order_cycle.id)
    @seller = current_user
    
    respond_to do |format|
      if cart_item.destroy
        send_order_modified_emails(@seller, cart_item.order)
        format.html { redirect_to packing_list_seller_index_path, notice: 'Item successfully deleted!'}
        format.js { render :nothing => true }
      else
        format.html { render :packing_list }
        format.js { render :packing_list, :layout => false, :status => 403 }
      end
    end
  end
  
  def update_order
    order = Order.find(params[:order_id])
    success = false
    @orders = get_packing_list_orders(order.order_cycle.id)
    @seller = current_user
    
    if params[:commit] == 'Delete All Items'
      order.cart_items.each do |item|
        item.destroy if item.inventory_item.user == @seller
      end
      success = true
    else
      success = order.update_attributes(params[:order])
    end
                   
    respond_to do |format|
      if success
        send_order_modified_emails(@seller, order)
        format.html { redirect_to packing_list_seller_index_path, notice: 'Order successfully updated!'}
        format.js { render :nothing => true }
      else
        format.html { render :packing_list }
        format.js { render :packing_list, :layout => false, :status => 403 }
      end
    end
  end
  
  private
  
  def send_order_modified_emails(seller, order)
    BuyerMailer.delay.order_modified_mail(seller, order)
    managers = Role.find_by_name("manager").users 
     managers.each do |manager|
       ManagerMailer.delay.seller_modified_order_mail(seller, manager, order)
     end
  end
  
  def get_packing_list_orders(order_cycle_id)
    seller = current_user
    Order.joins(:cart_items => :inventory_item)
         .select('orders.id, orders.user_id')
         .where(:inventory_items => {:user_id => seller.id}, :orders => {:order_cycle_id => order_cycle_id})
         .group('orders.id, orders.user_id')
  end
  
  def get_pick_list_inventory_items(order_cycle_id)
    user_id = current_user.id
    InventoryItem.joins(:cart_items => :order)
                  .where('inventory_items.user_id = ? AND orders.order_cycle_id = ?', user_id, order_cycle_id)
                  .select('inventory_items.id, inventory_items.name, inventory_items.price_unit, sum(cart_items.quantity)')
                  .group('inventory_items.id, inventory_items.name, inventory_items.price_unit')
  end
  
  def get_last_inventory(order_cycle_id)
    InventoryItem.joins(:order_cycle)
                 .where("order_cycles.id = ? AND user_id = ? AND is_deleted = ? AND approved = ?", order_cycle_id, current_user.id, false, true)
  end
  
  def get_current_inventory
    InventoryItem.joins(:order_cycle)
                 .where("order_cycles.status IN('current','pending') AND user_id = ? AND is_deleted = ?", current_user.id, false)
                 .order("created_at DESC")
  end
  
end
