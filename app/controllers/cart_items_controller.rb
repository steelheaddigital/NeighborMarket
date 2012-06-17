class CartItemsController < ApplicationController
  
  def new
    
  end
  
  def create
    @cart = current_cart
    inventory_item = InventoryItem.find(params[:inventory_item_id])
    @cart_item = @cart.add_inventory_item(inventory_item.id)
    
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
  
end
