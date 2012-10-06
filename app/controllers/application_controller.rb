class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_cart
  helper_method :current_order_cycle_pickup_date
  helper_method :current_order_cycle_end_date
  before_filter :set_time_zone
  before_filter :current_order_id
  before_filter :completed_order_id
  
  def set_time_zone
    Time.zone = SiteSetting.first.time_zone if SiteSetting.first
  end
  
  def current_order_id
    if user_signed_in? && current_user.buyer?
      current_order = current_user.orders.find_by_order_cycle_id(OrderCycle.current_cycle_id)
      @current_order_id = current_order.id if current_order
    end
  end
  
  def completed_order_id
    if user_signed_in? && current_user.buyer? && OrderCycle.pending_delivery && !OrderCycle.current_cycle
      completed_order = current_user.orders.joins(:order_cycle).where("order_cycles.buyer_pickup_date >= ? AND order_cycles.status = ?", DateTime.now.utc, "complete").last
      @completed_order_id = completed_order.id if completed_order
    end
  end
  
  def current_ability
    @current_ability ||= Ability.new(current_user, session)
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
