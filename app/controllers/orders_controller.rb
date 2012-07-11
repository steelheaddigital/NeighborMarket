class OrdersController < ApplicationController
  def new
    
    if(!user_signed_in? || !current_user.buyer?)
      render :not_buyer
      return
    end
    
    @order = Order.new
    @cart = current_cart
    @order.user_id = current_user.id
    @order.cart_items = @cart.cart_items
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def create
    @order = Order.new
    @order.user_id = current_user.id
    @order.add_inventory_items_from_cart(current_cart)
    
    respond_to do |format|
        if @order.save
          
          #decrement the available inventory for each item in the order
          @order.cart_items.each do |item|
            item.inventory_item.decrement_quantity_available(item.quantity)
          end
          
          Cart.destroy(session[:cart_id])
          session[:cart_id] = nil
          format.html {redirect_to home_index_url, notice: 'Your order has been submitted. Thank You!'}
        else
          @cart = current_cart
          format.html {redirect_to cart_index_url, notice: 'Sorry, your order could not be created' }
        end
    end
  end
end
