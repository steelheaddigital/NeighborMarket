class CartController < ApplicationController
  
  def index
    @cart = current_cart
    @total_price = @cart.total_price
    
    respond_to do |format|
      format.html
    end
  end
  
  def item_count
    @item_count = current_cart.cart_items.count
    
    respond_to do |format|
      format.json {render :json => @item_count}
    end
  end
end
