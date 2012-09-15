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
      
      @order = current_user.orders.build
      @order.cart_items = @cart.cart_items

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
    @order = current_user.orders.build
    @order.add_inventory_items_from_cart(current_cart)
    
    respond_to do |format|
        if @order.save
          
          #decrement the available inventory for each item in the order
          sellers_array = Array.new
          @order.cart_items.each do |item|
            item.inventory_item.decrement_quantity_available(item.quantity)
            sellers_array.push(item.inventory_item.user)
          end
        
          send_emails(@order, sellers_array)
        
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
  
  def send_emails(order, sellers_array)
    #Send an email to each seller notifying them of the sale
    sellers = sellers_array.uniq{|x| x.id}
    sellers.each do |seller|
      SellerMailer.delay.new_purchase_mail(seller, order)
    end
    
#    BuyerMailer.order_mail(current_user, order).deliver
  end
  
end
