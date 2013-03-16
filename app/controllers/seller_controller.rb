class SellerController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :class => InventoryItem
  skip_authorize_resource :only => :contact
  require 'will_paginate/array'
  
  def index    
    @all_inventory = get_past_inventory_items
    @current_inventory = get_current_inventory.paginate(:page => params[:page], :per_page => 10)
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def add_past_inventory
    items = params[:item]
    if items.nil?
      redirect_to seller_index_path, notice: 'Unable to add items, no items selected.'
      return
    end
    
    if OrderCycle.active_cycle.nil? 
      redirect_to seller_index_path, notice: 'Unable to add items, no available order cycle.'
      return
    else  
      items.each do |item|
        inventory_item = InventoryItem.find(item[1])
        inventory_item.add_to_order_cycle
        inventory_item.save
      end
    end
    respond_to do |format|
      format.html { redirect_to seller_index_path, notice: 'Items successfully added to your current inventory!' }
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
    InventoryItem.joins(:order_cycles)
                 .where("order_cycles.id = ? AND user_id = ? AND is_deleted = ? AND approved = ?", order_cycle_id, current_user.id, false, true)
  end
  
  def get_current_inventory
    InventoryItem.joins(:order_cycles)
                 .where("order_cycles.status IN('current','pending') AND user_id = ? AND is_deleted = ?", current_user.id, false)
                 .order("created_at DESC")
  end
  
  def get_past_inventory_items
    InventoryItem.joins("LEFT JOIN inventory_item_order_cycles ON inventory_items.id = inventory_item_order_cycles.inventory_item_id")
                 .where("inventory_item_order_cycles.inventory_item_id IS NULL AND user_id = ? AND is_deleted = ?", current_user.id, false)
                 .order("created_at DESC")
  end
  
end
