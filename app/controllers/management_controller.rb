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
    sql = 'SELECT cart_items.*, inv.last_name AS seller_last_name, inv.first_name AS seller_first_name, orders.last_name AS buyer_last_name, orders.first_name AS buyer_first_name
           FROM cart_items
           INNER JOIN (SELECT inventory_items.id, inventory_items.name, users.last_name, users.first_name FROM inventory_items INNER JOIN users ON users.id = inventory_items.user_id) AS inv ON cart_items.inventory_item_id = inv.id 
           INNER JOIN (SELECT orders.id, users.last_name, users.first_name FROM orders INNER JOIN users ON users.id = orders.user_id) AS orders ON orders.id = cart_items.order_id
           ORDER BY inv.last_name, inv.first_name, orders.last_name, orders.first_name'
    @items = CartItem.find_by_sql(sql)

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
