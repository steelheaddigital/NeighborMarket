class CartController < ApplicationController
  
  def index
    @cart = current_cart
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def item_count
    @item_count = current_cart.cart_items.count
    
    respond_to do |format|
      format.json {render :json => @item_count}
    end
  end
end
