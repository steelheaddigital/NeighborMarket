module CurrentCart
  extend ActiveSupport::Concern
  
  def set_cart
    Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound    
    if(user_signed_in?)
      cart = Cart.create(:user_id => current_user.id)
    else
      cart = Cart.create()
    end
    session[:cart_id] = cart.id
  end
  
  def current_cart
    if session[:cart_id].nil?
      Cart.new
    else
      Cart.find(session[:cart_id])
    end
  end
  
end