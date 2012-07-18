class OrdersController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => [:new]
  
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
          sellers_array = Array.new
          @order.cart_items.each do |item|
            item.inventory_item.decrement_quantity_available(item.quantity)
            sellers_array.push(item.inventory_item.user)
          end
          
          #Send an email to each seller notifying them of the sale
          sellers = sellers_array.uniq{|x| x.id}
          sellers.each do |seller|
            cart_items = @order.cart_items.joins(:inventory_item).where("inventory_items.user_id = ?", seller.id)
            SellerMailer.new_purchase_mail(seller, @order.user, cart_items).deliver
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
