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
        format.js { render :nothing => true }
      else
        message = @cart_item.errors.full_messages.first
        format.html { redirect_to cart_index_path, notice: message }
        format.js { render :text => "Item cannot be added to cart, " + message, :status => 403 }
      end
    end
    
  end
  
  def destroy
    @cart_item = CartItem.find(params[:cart_item_id])
      
    respond_to do |format|
      if @cart_item.destroy
        if @cart_item.order_id
          format.html{ redirect_to edit_order_path(@cart_item.order_id) }
          format.js { render :nothing => true }
        else
          format.html{ redirect_to cart_index_path }
          format.js { render :nothing => true }
        end 
      else
        format.html{ redirect_to cart_index_path, notice: "Cart item could not be deleted" }
        format.js { render :nothing => true, :status => 403  }
      end
    end
  end
  
end
