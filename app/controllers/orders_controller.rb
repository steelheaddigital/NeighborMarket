class OrdersController < ApplicationController
  def new
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
          Cart.destroy(session[:cart_id])
          session[:cart_id] = nil
          format.html {redirect_to home_index_url, notice: 'Thank you for your order'}
        else
          @cart = current_cart
          format.html {redirect_to cart_index_url, notice: 'Sorry, your order could not be created' }
        end
    end
  end
end
