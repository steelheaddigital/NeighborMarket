class CartController < ApplicationController
  
  def index
    @cart = current_cart
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
end
