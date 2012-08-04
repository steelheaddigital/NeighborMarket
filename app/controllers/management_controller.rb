class ManagementController < ApplicationController
  load_and_authorize_resource :class => ManagementController
  
  def index

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
      format.js { render :partial => "user_search", :layout => false }
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
    #Couldn't find a way to do the aliased subquery with ActiveRecord so just used raw SQL
    @items = CartItem.joins(:order)

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
    @orders = Order.order(:user_id, :id)
    
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
  
end
