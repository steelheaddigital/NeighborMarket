class SessionsController < Devise::SessionsController
  respond_to :html 
  def destroy
    
    cart_id = session["cart_id"]
    if cart_id
      cart = Cart.find(cart_id)
      cart.destroy if cart
    end
    
    super
  end  
end
