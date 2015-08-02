#
#Copyright 2013 Neighbor Market
#
#This file is part of Neighbor Market.
#
#Neighbor Market is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#Neighbor Market is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with Neighbor Market.  If not, see <http://www.gnu.org/licenses/>.
#

class ManagementController < ApplicationController
  require 'csv'
  require 'will_paginate/array'
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
  before_filter :authenticate_user!
  load_and_authorize_resource :class => InventoryItem
  load_and_authorize_resource :class => User
  load_and_authorize_resource :class => TopLevelCategory
  load_and_authorize_resource :class => SecondLevelCategory
  load_and_authorize_resource :class => OrderCycle
  load_and_authorize_resource :class => Order
  load_and_authorize_resource :class => CartItem
  load_and_authorize_resource :class => SiteSetting
  load_and_authorize_resource :class => PriceUnit
  load_and_authorize_resource :class => InventoryItemChangeRequest
  
  def edit_order_cycle_settings
    @order_cycle_settings = OrderCycleSetting.first ? OrderCycleSetting.first : OrderCycleSetting.new
    @order_cycle_settings.padding ||= 0
    @order_cycle = OrderCycle.get_order_cycle
    
    respond_to do |format|
      format.html
    end
  end
  
  def update_order_cycle_settings
    @order_cycle_settings = OrderCycleSetting.new_setting(params[:order_cycle_setting])
    @order_cycle_settings.padding ||= 0

    case params[:commit]
    when 'Save and Start New Cycle'
      @order_cycle = OrderCycle.build_initial_cycle(params[:order_cycle], @order_cycle_settings)
    when 'Update Settings'
      @order_cycle = OrderCycle.update_current_order_cycle(params[:order_cycle], @order_cycle_settings)
    end
    
    respond_to do |format|
      if @order_cycle_settings.save && @order_cycle.save_and_set_status
        format.html { redirect_to edit_order_cycle_settings_management_index_path, notice: 'Order Cycle Settings Successfully Saved!' }
      else
        format.html { render :edit_order_cycle_settings }
      end
    end
  end
  
  def approve_sellers
    @sellers = User.joins(:roles).where("approved_seller = false AND roles.name = 'seller'") 
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def user_search
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def add_users
    @user = User.new
    
    respond_to do |format|
      format.html 
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
    @categories = TopLevelCategory.where(:active => true)
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
    
  end
  
  def inbound_delivery_log
    if !params[:selected_previous_order_cycle].nil?
      order_cycle = OrderCycle.find(params[:selected_previous_order_cycle][:id])
    else
      order_cycle = OrderCycle.latest_cycle
    end
    @items = CartItem.joins(:order).where(minimum_reached_at_order_cycle_end: true, orders: { order_cycle_id: order_cycle.id, canceled: false })
    @previous_order_cycles = OrderCycle.last_ten_cycles
    @selected_previous_order_cycle = @previous_order_cycles.find { |e| e.id == order_cycle.id }

    if params[:commit] == 'Printable Delivery Log (PDF)'
      output = InboundDeliveryLog.new.to_pdf(@items)
      send_data output, :filename => "inbound_delivery_log.pdf",
                        :type => "application.pdf"
    end
  end
  
  def save_inbound_delivery_log
    items = params[:cart_items]
    if !params[:selected_previous_order_cycle].nil?
      order_cycle = OrderCycle.find(params[:selected_previous_order_cycle][:id])
    else
      order_cycle = OrderCycle.latest_cycle
    end
    previous_order_cycles = OrderCycle.last_ten_cycles
    selected_previous_order_cycle = previous_order_cycles.find{|e| e.id == order_cycle.id}
    
    #Loop through the cart_items array passed in and update the delivered attribute for each
    items.each do |item|
      cart_item = CartItem.find(item[1][:id])
      if(item[1][:delivered])
        cart_item.update_attribute(:delivered, true)
      else
        cart_item.update_attribute(:delivered, false)
      end
    end
    
    respond_to do |format|
        format.html { redirect_to inbound_delivery_log_management_index_path, :selected_previous_order_cycle => selected_previous_order_cycle, notice: 'Delivery Log Successfully Saved!'}
    end
  end
  
  def outbound_delivery_log
    if !params[:selected_previous_order_cycle].nil?
      order_cycle = OrderCycle.find(params[:selected_previous_order_cycle][:id])
    else
      order_cycle = OrderCycle.latest_cycle
    end
    @orders = Order.active.joins(:cart_items).order(:user_id, :id).where(cart_items: { minimum_reached_at_order_cycle_end: true }, orders: { order_cycle_id: order_cycle.id, canceled: false }).distinct
    @previous_order_cycles = OrderCycle.last_ten_cycles
    @selected_previous_order_cycle = @previous_order_cycles.find { |e| e.id == order_cycle.id }
    
    if params[:commit] == 'Printable Delivery Log (PDF)'
      output = OutboundDeliveryLog.new.to_pdf(@orders)
      send_data output, filename: 'outbound_delivery_log.pdf',
                        type: 'application.pdf'
    end
  end
  
  def save_outbound_delivery_log
    orders = params[:orders]
    if !params[:selected_previous_order_cycle].nil?
      order_cycle = OrderCycle.find(params[:selected_previous_order_cycle][:id])
    else
      order_cycle = OrderCycle.latest_cycle
    end
    previous_order_cycles = OrderCycle.last_ten_cycles
    selected_previous_order_cycle = previous_order_cycles.find{|e| e.id == order_cycle.id}
    
    #Loop through the orders array passed in and update the delivered attribute for each
    orders.each do |order_params|
      order = Order.find(order_params[1][:id])
      if(order_params[1][:complete])
        order.update_attribute(:complete, true)
      else
        order.update_attribute(:complete, false)
      end
    end
    
    respond_to do |format|
        format.html { redirect_to outbound_delivery_log_management_index_path, :selected_previous_order_cycle => selected_previous_order_cycle, notice: 'Delivery Log Successfully Saved!'}
    end
  end
  
  def buyer_invoices
    if !params[:selected_previous_order_cycle].nil?
      order_cycle = OrderCycle.find(params[:selected_previous_order_cycle][:id])
    else
      order_cycle = OrderCycle.latest_cycle
    end
    @orders = Order.active.joins(:cart_items).order(:user_id, :id).where(cart_items: { minimum_reached_at_order_cycle_end: true }, orders: {order_cycle_id: order_cycle.id, canceled: false }).distinct
    @previous_order_cycles = OrderCycle.last_ten_cycles
    @selected_previous_order_cycle = @previous_order_cycles.find{|e| e.id == order_cycle.id}
    @site_settings = SiteSetting.instance
    
    if params[:commit] == 'Printable Invoices (PDF)'
      output = BuyerInvoices.new.to_pdf(@orders, @site_settings)
      send_data output, :filename => "buyer_invoices.pdf",
                        :type => "application.pdf"
    end
  end
  
  def inventory_item_approval
    @inventory_items = InventoryItem.where(:approved => false)
    
    respond_to do |format|
      format.html
    end
  end
  
  def update_inventory_item_approval
    inventory_items = params[:inventory_items]
    inventory_items.each do |item|
      inventory_item = InventoryItem.find(item[1][:id])
      if(item[1][:approved])
        inventory_item.update_attribute(:approved, true)
      else
        inventory_item.update_attribute(:approved, false)
      end
    end
    
    respond_to do |format|
        format.html { redirect_to inventory_item_approval_management_index_path, notice: 'Inventory Items Successfully Updated!'}
    end
  end
  
  def inventory
    @inventory_items = InventoryItem.joins(:order_cycles)
                                    .where("quantity_available > 0 AND is_deleted = false AND order_cycles.status = 'current'")
                                    .paginate(:page => params[:page], :per_page => 15)
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def edit_inventory
    @item = InventoryItem.find(params[:id])
    @top_level_categories = TopLevelCategory.all
    @second_level_categories = SecondLevelCategory.where(:top_level_category_id => @item.top_level_category.id)
    @inventory_guidelines = SiteContent.instance.inventory_guidelines
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def historical_orders
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def historical_orders_report
    if params[:start_date].values.any?(&:blank?) || params[:end_date].values.any?(&:blank?)
      @orders = Order.active.joins(:cart_items).where(cart_items: {minimum_reached_at_order_cycle_end: true}).order(:id).distinct
    else
      begin_date = DateTime.new(params[:start_date][:year].to_i,params[:start_date][:month].to_i,params[:start_date][:day].to_i)
      end_date = DateTime.new(params[:end_date][:year].to_i,params[:end_date][:month].to_i,params[:end_date][:day].to_i)
      @orders = Order.active.joins(:order_cycle, :cart_items)
                .where(cart_items: { minimum_reached_at_order_cycle_end: true }, order_cycles: { end_date: begin_date..end_date + 1.day })
                .order(:id).distinct
    end
    if params[:commit] == "Export to CSV"
      report_name = "historical_orders_#{Date.today.strftime('%d%b%y')}.csv" 
      send_data historical_orders_report_csv(@orders), 
       :type => 'text/csv; charset=iso-8859-1; header=present', 
       :disposition => "attachment; filename=#{report_name}"
    else
      respond_to do |format|
        format.html
        format.js { render :layout => false }
      end
    end       
  end

  def new_users_report
    if params[:start_date].nil? || params[:end_date].nil?
      @start_date = Time.now - 30.days
      @end_date = Time.now
    else
      @start_date = DateTime.new(params[:start_date][:year].to_i,params[:start_date][:month].to_i,params[:start_date][:day].to_i)
      @end_date = DateTime.new(params[:end_date][:year].to_i,params[:end_date][:month].to_i,params[:end_date][:day].to_i)
    end
    @users = User.active.where(:created_at => @start_date..@end_date + 1.day).order(:created_at)
    
    respond_to do |format|
      format.html
    end
  end
  
  def deleted_users_report
    if params[:start_date].nil? || params[:end_date].nil?
      @start_date = Time.now - 30.days
      @end_date = Time.now
    else
      @start_date = DateTime.new(params[:start_date][:year].to_i,params[:start_date][:month].to_i,params[:start_date][:day].to_i)
      @end_date = DateTime.new(params[:end_date][:year].to_i,params[:end_date][:month].to_i,params[:end_date][:day].to_i)
    end
    @users = User.where(:deleted_at => @start_date..@end_date + 1.day).order(:deleted_at)
    
    respond_to do |format|
      format.html
    end
  end
  
  def updated_user_profile_report
    if params[:start_date].nil? || params[:end_date].nil?
      @start_date = Time.now - 30.days
      @end_date = Time.now
    else
      @start_date = DateTime.new(params[:start_date][:year].to_i,params[:start_date][:month].to_i,params[:start_date][:day].to_i)
      @end_date = DateTime.new(params[:end_date][:year].to_i,params[:end_date][:month].to_i,params[:end_date][:day].to_i)
    end
    @users = User.where(:updated_at => @start_date..@end_date + 1.day, :deleted_at => nil).order(:updated_at)
    
    respond_to do |format|
      format.html
    end
  end

  def manage_units
    @price_units = PriceUnit.all
    @new_unit = PriceUnit.new
    @added_units = get_added_units
  
    respond_to do |format|
      format.html
    end
  end
  
  def create_price_unit
    @price_units = PriceUnit.all
    @new_unit = PriceUnit.new(params[:price_unit])
    @added_units = get_added_units
  
    respond_to do |format|
      if @new_unit.save
        format.html { redirect_to manage_units_management_index_path, notice: 'Unit successfully saved!'}
      else
        format.html { render :manage_units }
      end
    end
  end
  
  def destroy_price_unit
    price_unit = PriceUnit.find(params[:price_unit])
    
    respond_to do |format|
      if price_unit.destroy
        format.html{ redirect_to manage_units_management_index_path, notice: "Unit successfully deleted!" }
      else
        format.html{ redirect_to manage_units_management_index_path, notice: 'Unable to delete the unit' }
      end
    end
  end

  def inventory_item_change_requests
    @requests = InventoryItemChangeRequest.where(:complete => false)
    
    respond_to do |format|
      format.html
    end
  end
  
  def order_change_requests
    @requests = OrderChangeRequest.where(:complete => false)
    
    respond_to do |format|
      format.html
    end
  end

  def test_email
    email = current_user.email
    
    ManagerMailer.test_email(email).deliver
    
    respond_to do |format|
      format.html { redirect_to site_settings_path, notice: 'Email sent to your email address. If you do not recieve it, please check your email settings.' }
    end
    
  end

  private
  
  def historical_orders_report_csv(orders)
    CSV.generate do |csv|
      csv << ["Seller ID", "Buyer ID", "Order ID", "Item Name", "Quantity", "Price", "Delivery Date"]
      orders.each do |order|
        buyer_id = order.user.id
        order_id = order.id
        delivery_date = order.order_cycle.seller_delivery_date
        order.cart_items_where_order_cycle_minimum_reached.each do |cart_item|
          csv << [cart_item.inventory_item.user.id, buyer_id, order_id, cart_item.inventory_item.name, cart_item.quantity, number_to_currency(cart_item.inventory_item.price).to_s, format_short_date(delivery_date)]
        end
      end
    end
  end 
  
  def get_added_units
    InventoryItem.joins("LEFT OUTER JOIN price_units ON price_units.name = inventory_items.price_unit")
                 .where("price_units.name IS NULL")
                 .select("DISTINCT inventory_items.price_unit")
  end

end
