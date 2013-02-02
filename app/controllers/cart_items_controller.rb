class CartItemsController < ApplicationController
  load_and_authorize_resource :only => [:destroy]
  
  def create
    @cart = current_cart
    inventory_item_id = params[:inventory_item_id]
    quantity = params[:quantity]
    @cart_item = @cart.add_inventory_item(inventory_item_id, quantity)
    
    respond_to do |format|
      if @cart_item.save
        format.html { redirect_to cart_index_path }
      else
        message = @cart_item.errors.full_messages.first
        format.html { redirect_to cart_index_path, notice: message }
      end
    end
    
  end
  
  def destroy
    @cart_item = CartItem.find(params[:cart_item_id])
      
    respond_to do |format|
      if @cart_item.destroy
        if @cart_item.order_id
          if Order.exists?(@cart_item.order_id)
            format.html{ redirect_to edit_order_path(@cart_item.order_id) }
          else
            format.html{ redirect_to root_path, notice: "You have deleted all items in your order. Your order has been cancelled."}
          end
        else
          format.html{ redirect_to cart_index_path }
        end 
      else
        format.html{ redirect_to cart_index_path, notice: "Cart item could not be deleted" }
      end
    end
  end
  
end
