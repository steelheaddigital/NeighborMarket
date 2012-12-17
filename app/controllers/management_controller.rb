class ManagementController < ApplicationController
  load_and_authorize_resource :class => ManagementController
  
  def index
    @site_settings = SiteSetting.first ? SiteSetting.first : SiteSetting.new
    
    render :template => 'site_setting/edit'
  end
  
  def approve_sellers
    @sellers = User.joins(:roles).where("approved_seller = false AND roles.name = 'seller'") 
    
    #if the view is being loaded via ajax, don't render the layout
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def user_management
    
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
      format.pdf { render :layout => false }
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
  
end
