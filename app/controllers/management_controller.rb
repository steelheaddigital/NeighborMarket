class ManagementController < ApplicationController
  require 'csv'
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
  load_and_authorize_resource :class => InventoryItem
  load_and_authorize_resource :class => User
  load_and_authorize_resource :class => TopLevelCategory
  load_and_authorize_resource :class => SecondLevelCategory
  load_and_authorize_resource :class => OrderCycle
  load_and_authorize_resource :class => Order
  load_and_authorize_resource :class => CartItem
  load_and_authorize_resource :class => SiteSetting
  
  def edit_site_settings
    @site_settings = SiteSetting.first ? SiteSetting.first : SiteSetting.new
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def update_site_settings
    @site_settings = SiteSetting.new_setting(params[:site_setting])
    
    respond_to do |format|
      if @site_settings.save
        format.html { redirect_to edit_site_settings_management_index_path, notice: 'Site Settings Successfully Saved!'}
        format.js { render :nothing => true }
      else
        format.html { render :edit }
        format.js { render :edit, :layout => false, :status => 403 }
      end
    end
  end
  
  def edit_order_cycle_settings
    @order_cycle_settings = OrderCycleSetting.first ? OrderCycleSetting.first : OrderCycleSetting.new
    @order_cycle_settings.padding ||= 0
    @order_cycle = get_order_cycle
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def update_order_cycle_settings
    @order_cycle_settings = OrderCycleSetting.new_setting(params[:order_cycle_setting])
    @order_cycle_settings.padding ||= 0
    @order_cycle = OrderCycle.build_initial_cycle(params[:order_cycle], @order_cycle_settings)
      
    respond_to do |format|
      if @order_cycle_settings.save and (params[:commit] == 'Save and Start New Cycle' ? @order_cycle.save_and_set_status : true)
        format.html { redirect_to edit_order_cycle_settings_management_index_path, notice: 'Order Cycle Settings Successfully Saved!'}
        format.js { render :nothing => true }
      else
        format.html { render :edit_order_cycle_settings }
        format.js { render :edit_order_cycle_settings, :layout => false, :status => 403 }
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
      format.js { render :layout => false }
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
    @categories = TopLevelCategory.all
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
    
  end
  
  def inbound_delivery_log
    current_cycle_id = OrderCycle.current_cycle_id
    @items = CartItem.joins(:order).where(:orders => {:order_cycle_id => current_cycle_id})

    respond_to do |format|
      format.html
      format.js { render :layout => false }
      format.pdf do
        output = InboundDeliveryLog.new.to_pdf(@items)
        send_data output, :filename => "inbound_delivery_log.pdf",
                          :type => "application.pdf"
      end
    end
  end
  
  def save_inbound_delivery_log
    cart_items = params[:cart_items]
    
    #Loop through the cart_items array passed in and update the delivered attribute for each
    cart_items.each do |item|
      cart_item = CartItem.find(item[1][:id])
      if(item[1][:delivered])
        cart_item.update_attribute(:delivered, true)
      else
        cart_item.update_attribute(:delivered, false)
      end
    end
    
    respond_to do |format|
        format.html { redirect_to inbound_delivery_log_management_index_path, notice: 'Delivery Log Successfully Saved!'}
        format.js { render :nothing => true }
    end
  end
  
  def outbound_delivery_log
    current_cycle_id = OrderCycle.current_cycle_id
    @orders = Order.order(:user_id, :id).where(:orders => {:order_cycle_id => current_cycle_id})
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
      format.pdf do
        output = OutboundDeliveryLog.new.to_pdf(@orders)
        send_data output, :filename => "outbound_delivery_log.pdf",
                          :type => "application.pdf"
      end
    end
  end
  
  def save_outbound_delivery_log
    orders = params[:orders]
    
    #Loop through the orders array passed in and update the delivered attribute for each
    orders.each do |order|
      cart_item = Order.find(order[1][:id])
      if(order[1][:complete])
        cart_item.update_attribute(:complete, true)
      else
        cart_item.update_attribute(:complete, false)
      end
    end
    
    respond_to do |format|
        format.html { redirect_to outbound_delivery_log_management_index_path, notice: 'Delivery Log Successfully Saved!'}
        format.js { render :nothing => true }
    end
  end
  
  def buyer_invoices
    current_cycle_id = OrderCycle.current_cycle_id
    @orders = Order.order(:user_id, :id).where(:orders => {:order_cycle_id => current_cycle_id})
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
      format.pdf do
        output = BuyerInvoices.new.to_pdf(@orders)
        send_data output, :filename => "buyer_invoices.pdf",
                          :type => "application.pdf"
      end
    end
  end
  
  def inventory_item_approval
    @inventory_items = InventoryItem.where(:approved => false)
    
    respond_to do |format|
      format.html
      format.js {render :layout => false}
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
        format.js { render :nothing => true }
    end
  end
  
  def inventory
    @inventory_items = InventoryItem.where("quantity_available > 0")
    
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
  
  def edit_inventory
    @item = InventoryItem.find(params[:id])
    @top_level_categories = TopLevelCategory.all
    @second_level_categories = SecondLevelCategory.find_all_by_top_level_category_id(@item.top_level_category.id)
    
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
      @orders = Order.all
    else
      begin_date = DateTime.new(params[:start_date][:year].to_i,params[:start_date][:month].to_i,params[:start_date][:day].to_i)
      end_date = DateTime.new(params[:end_date][:year].to_i,params[:end_date][:month].to_i,params[:end_date][:day].to_i)
      @orders = Order.joins(:order_cycle)
                     .where(:order_cycles => {:end_date => begin_date..end_date})
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


  private
  
  def historical_orders_report_csv(orders)
    CSV.generate do |csv|
      csv << ["Seller ID", "Buyer ID", "Order ID", "Item Name", "Quantity", "Price", "Delivery Date"]
      orders.each do |order|
        buyer_id = order.user.id
        order_id = order.id
        delivery_date = order.order_cycle.seller_delivery_date
        order.cart_items.each do |cart_item|
          csv << [cart_item.inventory_item.user.id, buyer_id, order_id, cart_item.inventory_item.name, cart_item.quantity, number_to_currency(cart_item.inventory_item.price).to_s + " " + price_unit_label(cart_item.inventory_item), format_short_date(delivery_date)]
        end
      end
    end
  end 
  
  def get_order_cycle
    if OrderCycle.find_by_status("current")
      order_cycle = OrderCycle.find_by_status("current")
    elsif 
      OrderCycle.find_by_status("pending")
      order_cycle = OrderCycle.find_by_status("pending")
    else
      order_cycle = OrderCycle.new
    end

    return order_cycle
  end

end
