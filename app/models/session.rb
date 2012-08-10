class Session < ActiveRecord::Base
  before_destroy :clean_carts

  def marshal(data)   Base64.encode64(Marshal.dump(data)) if data end
  def unmarshal(data) Marshal.load(Base64.decode64(data)) if data end
  
  attr_accessible :data, :session_id
  
  def clean_carts
    data = self.unmarshal(self.data)
    cart_id = data["cart_id"]
    if cart_id
      cart = Cart.find(cart_id)
      cart.destroy if cart
    end
  end
end


