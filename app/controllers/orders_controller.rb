class OrdersController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => [:new]
  
  def new
    @cart = current_cart
    #update the cart in case the user changed any quantitities
    if @cart.update_attributes(params[:cart])
      
      if(!user_signed_in? || !current_user.buyer?)
        render :not_buyer
        return
      end
      
      @current_order = current_user.orders.find_by_order_cycle_id(OrderCycle.current_cycle_id)
      if @current_order
        @order = @current_order
        @order.cart_items.concat(@cart.cart_items)
      else
        @order = current_user.orders.build
        @order.cart_items = @cart.cart_items
      end
      
      respond_to do |format|
        format.html
        format.js { render :layout => false }
      end
    else
      message = @cart.errors.full_messages.first
      redirect_to cart_index_path, :notice => message
    end
    
  end
  
  def create
      
    current_order = current_user.orders.find_by_order_cycle_id(OrderCycle.current_cycle_id)
    if current_order
      @order = current_order
    else
      @order = current_user.orders.build
    end
    
    @order.add_inventory_items_from_cart(current_cart)
    
    respond_to do |format|
        if @order.save
          send_emails(@order, false)
        
          Cart.destroy(session[:cart_id])
          session[:cart_id] = nil
          
          @order_pickup_date = OrderCycle.current_cycle.buyer_pickup_date
          @site_settings = SiteSetting.first
          format.html {render :finish}
        else
          @cart = current_cart
          format.html {redirect_to cart_index_url, notice: 'Sorry, your order could not be created' }
        end
    end
  end
  
  def edit
    @order = Order.find(params[:id])
    @total_price = @order.total_price
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def update
    @order = Order.find(params[:id])
    @total_price = @order.total_price
    
    respond_to do |format|
      if @order.update_attributes(params[:order])
        send_emails(@order, true)
        
        format.html { redirect_to edit_order_path, notice: 'Order successfully updated!'}
        format.js { render :edit, :layout => false }
      else
        format.html { render "edit" }
        format.js { render :edit, :layout => false, :status => 403 }
      end
    end
  end
  
  def show
    @order = Order.find(params[:id])    
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def destroy
    @order = Order.find(params[:id])
          
    respond_to do |format|
      if @order.destroy
        format.html{ redirect_to root_path, notice: "Order successfully cancelled" }
        format.js { render :nothing => true }
      else
        format.html{ redirect_to edit_order_path(@order.id), notice: "Order could not be cancelled" }
        format.js { render :nothing => true, :status => 403  }
      end
    end
  end
  
  private
  
  def send_emails(order, update)
    #Send an email to each seller notifying them of the sale
    sellers_array = get_sellers(order)
    sellers = sellers_array.uniq{|x| x.id}
    if update
      sellers.each do |seller|
        SellerMailer.delay.updated_purchase_mail(seller, order)
      end
    else
      sellers.each do |seller|
        SellerMailer.delay.new_purchase_mail(seller, order)
      end
    end

    BuyerMailer.delay.order_mail(current_user, order)
  end
  
  def get_sellers(order)
    sellers_array = Array.new
    order.cart_items.each do |item|
      sellers_array.push(item.inventory_item.user)
    end
    
    return sellers_array
  end
  
end
