class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :current_cart
  
  def current_cart
    Cart.find(session[:cart_id])
    
  rescue ActiveRecord::RecordNotFound
    
    if(user_signed_in?)
      @cart = Cart.create(:user_id => current_user.id)
    else
      @cart = Cart.create()
    end
    
    session[:cart_id] = @cart.id
    @cart
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to new_user_session_url
  end
  
end
