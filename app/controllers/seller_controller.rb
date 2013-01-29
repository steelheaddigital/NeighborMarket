class SellerController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :class => InventoryItem
  skip_authorize_resource :only => :contact
  require 'will_paginate/array'
  
  def index
    if !params[:selected_previous_order_cycle].nil?
      order_cycle = OrderCycle.find(params[:selected_previous_order_cycle][:id])
      @show_past_inventory_container = "in"
    else
      order_cycle = OrderCycle.last_completed
      @show_past_inventory_container = ""
    end
    
    @last_inventory = get_last_inventory(order_cycle.id)
    @current_inventory = get_current_inventory.paginate(:page => params[:page], :per_page => 10)
    @previous_order_cycles = OrderCycle.last_ten_cycles
    @selected_previous_order_cycle = @previous_order_cycles.find{|e| e.id == order_cycle.id}
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
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
    end
  end
  
  def pick_list
    if !params[:selected_previous_order_cycle].nil?
      order_cycle = OrderCycle.find(params[:selected_previous_order_cycle][:id])
    else
      order_cycle = OrderCycle.latest_cycle
    end
    @inventory_items = get_pick_list_inventory_items(order_cycle.id)
    @previous_order_cycles = OrderCycle.last_ten_cycles
    @selected_previous_order_cycle = @previous_order_cycles.find{|e| e.id == order_cycle.id}
    
    respond_to do |format|
      format.html
      format.pdf do
        output = PickList.new.to_pdf(@inventory_items)
        send_data output, :filename => "pick_list.pdf",
                          :type => "application.pdf"
      end
    end
  end
  
  def packing_list
    if !params[:selected_previous_order_cycle].nil?
      order_cycle = OrderCycle.find(params[:selected_previous_order_cycle][:id])
    else
      order_cycle = OrderCycle.latest_cycle
    end
    @seller = current_user
    @orders = get_packing_list_orders(order_cycle.id)
    @previous_order_cycles = OrderCycle.last_ten_cycles
    @selected_previous_order_cycle = @previous_order_cycles.find{|e| e.id == order_cycle.id}
    @can_edit = order_cycle.status == "current"
    
    respond_to do |format|
      format.html
      format.pdf do
        output = PackingList.new.to_pdf(@orders, @seller)
        send_data output, :filename => "packing_list.pdf",
                          :type => "application.pdf"
      end
    end
  end
  
  def remove_item_from_order
    cart_item = CartItem.find(params[:cart_item_id])
    authorize! :delete, cart_item
    @orders = get_packing_list_orders(cart_item.order.order_cycle.id)
    @seller = current_user
    
    respond_to do |format|
      if cart_item.destroy
        send_order_modified_emails(@seller, cart_item.order)
        format.html { redirect_to packing_list_seller_index_path, notice: 'Item successfully deleted!'}
      else
        format.html { render :packing_list }
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
        authorize! :delete, item
        item.destroy
      end
      success = true
    else
      authorize! :update, order
      success = order.update_attributes(params[:order])
    end
                   
    respond_to do |format|
      if success
        send_order_modified_emails(@seller, order)
        format.html { redirect_to packing_list_seller_index_path, notice: 'Order successfully updated!'}
      else
        format.html { render :packing_list }
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
                  .where('inventory_items.user_id = ? AND orders.order_cycle_id = ? AND cart_items.order_id IS NOT NULL', user_id, order_cycle_id)
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
