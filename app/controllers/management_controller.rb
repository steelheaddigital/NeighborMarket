class ManagementController < ApplicationController
  require 'order_cycle_end_job'
  load_and_authorize_resource :class => ManagementController
  
  def index
    @site_settings = SiteSetting.first ? SiteSetting.first : SiteSetting.new
    
    render :action => "site_setting" 
  end
  
  def approve_sellers
    @sellers = User.joins(:roles).where("approved_seller = false AND roles.name = 'seller'") 
    
    #if the view is being loaded via ajax, don't render the layout
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def user_search
    
    respond_to do |format|
      format.html {render :index}
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
      format.pdf { render :layout => false }
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
        format.html { redirect_to management_inbound_delivery_log_path, notice: 'Delivery Log Successfully Saved!'}
        format.js { render :nothing => true }
    end
  end
  
  def outbound_delivery_log
    current_cycle_id = OrderCycle.current_cycle_id
    @orders = Order.order(:user_id, :id).where(:orders => {:order_cycle_id => current_cycle_id})
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
      format.pdf { render :layout => false }
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
        format.html { redirect_to management_outbound_delivery_log_path, notice: 'Delivery Log Successfully Saved!'}
        format.js { render :nothing => true }
    end
  end
  
  def buyer_invoices
    current_cycle_id = OrderCycle.current_cycle_id
    @orders = Order.order(:user_id, :id).where(:orders => {:order_cycle_id => current_cycle_id})
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
      format.pdf { render :layout => false }
    end
  end
  
  def order_cycle
    @order_cycle_settings = OrderCycleSetting.first ? OrderCycleSetting.first : OrderCycleSetting.new
    @order_cycle = OrderCycle.find_by_status("current")  ? OrderCycle.find_by_status("current") : OrderCycle.new
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def update_order_cycle
    @order_cycle_settings = OrderCycleSetting.new_setting(params[:order_cycle_setting])
    @order_cycle = OrderCycle.new_cycle(params[:order_cycle], @order_cycle_settings)
    @order_cycle.status = "current"
      
    respond_to do |format|
      if @order_cycle.save && @order_cycle_settings.save
        queue_order_cycle_end_job(@order_cycle.end_date)
        format.html { redirect_to management_order_cycle_path, notice: 'Order Cycle Settings Successfully Saved!'}
        format.js { render :nothing => true }
      else
        format.html { render "order_cycle" }
        format.js { render :order_cycle, :layout => false, :status => 403 }
      end
    end
  end
  
  def queue_order_cycle_end_job(end_date)
    job = OrderCycleEndJob.new
    Delayed::Job.where(:queue => "order_cycle_end").each do |job|
      job.destroy
    end
    Delayed::Job.enqueue(job, 0, end_date, :queue => 'order_cycle_end')
  end
  
  def site_setting
    @site_settings = SiteSetting.first ? SiteSetting.first : SiteSetting.new
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def update_site_setting
    @site_settings = SiteSetting.new_setting(params[:site_setting])
    
    respond_to do |format|
      if @site_settings.save
        format.html { redirect_to management_site_setting_path, notice: 'Site Settings Successfully Saved!'}
        format.js { render :nothing => true }
      else
        format.html { render "site_setting" }
        format.js { render :site_setting, :layout => false, :status => 403 }
      end
    end
  end
  
end
