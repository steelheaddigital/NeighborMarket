class CartItemsController < ApplicationController
  
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
        format.html { render "new" }
        format.js { render :new, :layout => false }
      end
    end
    
  end
  
  def destroy
    @cart_item = CartItem.find(params[:id])
    @cart_item.destroy

    respond_to do |format|
      format.html{ redirect_to cart_index_path }
      format.js { render :nothing => true }
    end
  end
  
end
