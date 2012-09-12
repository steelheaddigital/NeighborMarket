class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_cart
  helper_method :current_order_cycle_pickup_date
  helper_method :current_order_cycle_end_date
  before_filter :set_time_zone
  
  def set_time_zone
    Time.zone = SiteSetting.first.time_zone if SiteSetting.first
  end
  
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
