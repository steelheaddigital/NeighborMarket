class ApplicationController < ActionController::Base
  protect_from_forgery
  
  private
  
  def current_cart
    Cart.find(session[:cart_id])
    
  rescue ActiveRecord::RecordNotFound
    
    if(user_signed_in?)
      cart = Cart.create(:user_id => current_user.id)
    else
      cart = Cart.create()
    end
    
    session[:cart_id] = cart.id
    cart
  end
  
end
