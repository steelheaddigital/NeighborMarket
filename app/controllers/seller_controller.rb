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

class SellerController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :class => InventoryItem
  skip_authorize_resource :only => :contact
  require 'will_paginate/array'
  require 'csv'
  
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
        output = PickList.new.to_pdf(@inventory_items, @selected_previous_order_cycle)
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
  
  def sales_report
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def sales_report_details
    if params[:start_date].values.any?(&:blank?) || params[:end_date].values.any?(&:blank?)
      @begin_date = OrderCycle.first.end_date
      @end_date = DateTime.now
      @items = get_sales_report_details_all
    else
      @begin_date = DateTime.new(params[:start_date][:year].to_i,params[:start_date][:month].to_i,params[:start_date][:day].to_i)
      @end_date = DateTime.new(params[:end_date][:year].to_i,params[:end_date][:month].to_i,params[:end_date][:day].to_i)
      @items = get_sales_report_details(@begin_date, @end_date)
    end
    @total_price = @items.map{|i| i.attributes["total_price"].to_i}.reduce(:+)
    @total_quantity = @items.map{|i| i.attributes["total_quantity"].to_i}.reduce(:+)
    
    if params[:commit] == "Export to CSV"
      report_name = "sales_report_#{Date.today.strftime('%d%b%y')}.csv" 
      send_data sales_report_csv(@items), 
       :type => 'text/csv; charset=iso-8859-1; header=present', 
       :disposition => "attachment; filename=#{report_name}"
    else
      respond_to do |format|
        format.html
        format.js { render :layout => false }
      end
    end 
  end
  
  def reviews
    @inventory_items = InventoryItem.joins(:reviews).where(user_id: current_user.id).uniq
    @average_rating = current_user.avg_seller_rating
    
    respond_to do |format|
      format.html
    end
  end
  
  private
  def sales_report_csv(items)
    CSV.generate do |csv|
      csv << ["Item Name", "Price Per Unit", "Total Units Sold", "Total Price"]
      items.each do |item|
        csv << [item.name, item.price, item.attributes["total_quantity"], item.attributes["total_price"]]
      end
    end
  end 
  
  def get_sales_report_details_all
    seller = current_user
    InventoryItem.joins(:cart_items => { :order => :order_cycle })
                 .select('inventory_items.*, sum(cart_items.quantity) as total_quantity, sum(cart_items.quantity * inventory_items.price) as total_price')
                 .where(:inventory_items => {:user_id => current_user.id}, :cart_items => {minimum_reached_at_order_cycle_end: true})
                 .group('inventory_items.id, inventory_items.name')
  end
  
  def get_sales_report_details(begin_date, end_date)
    seller = current_user
    InventoryItem.joins(:cart_items => { :order => :order_cycle })
                 .select('inventory_items.*, sum(cart_items.quantity) as total_quantity, sum(cart_items.quantity * inventory_items.price) as total_price')
                 .where(:inventory_items => {:user_id => current_user.id}, :order_cycles => {:end_date => begin_date..end_date + 1.day}, :cart_items => {minimum_reached_at_order_cycle_end: true})
                 .group('inventory_items.id, inventory_items.name')
  end
  
  def get_packing_list_orders(order_cycle_id)
    seller = current_user
    Order.joins(:cart_items => :inventory_item)
         .select('orders.id, orders.user_id')
         .where(:inventory_items => {:user_id => seller.id}, :orders => {:order_cycle_id => order_cycle_id }, :cart_items => {minimum_reached_at_order_cycle_end: true})
         .group('orders.id, orders.user_id')
  end
  
  def get_pick_list_inventory_items(order_cycle_id)
    user_id = current_user.id
    InventoryItem.joins(:cart_items => :order)
                  .where('inventory_items.user_id = ? AND orders.order_cycle_id = ? AND cart_items.order_id IS NOT NULL AND cart_items.minimum_reached_at_order_cycle_end = TRUE', user_id, order_cycle_id)
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
    InventoryItem.joins("LEFT JOIN (SELECT inventory_item_id FROM inventory_item_order_cycles 
                        INNER JOIN order_cycles ON order_cycles.id = inventory_item_order_cycles.order_cycle_id 
                        AND order_cycles.status IN('current','pending')) AS j ON j.inventory_item_id = inventory_items.id
                        INNER JOIN top_level_categories AS t ON t.id = inventory_items.top_level_category_id
                        INNER JOIN second_level_categories AS s ON s.id = inventory_items.second_level_category_id")
                 .where("j.inventory_item_id IS NULL AND user_id = ? AND is_deleted = ? AND t.active = ? AND s.active = ?", current_user.id, false, true, true)
                 .order("created_at DESC")
  end
  
end
