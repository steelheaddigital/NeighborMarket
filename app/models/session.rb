#
#Copyright 2013 Neighbor Market
#
#This file is part of Neighbor Market.
#
#Neighbor Market is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#Neighbor Market is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with Neighbor Market.  If not, see <http://www.gnu.org/licenses/>.
#

class Session < ActiveRecord::Base
  before_destroy :clean_carts

  def marshal(data)   Base64.encode64(Marshal.dump(data)) if data end
  def unmarshal(data) Marshal.load(Base64.decode64(data)) if data end
  
  attr_accessible :data
  
  def clean_carts
    data = self.unmarshal(self.data)
    cart_id = data["cart_id"]
    if cart_id
      cart = Cart.find(cart_id)
      cart.destroy if cart
    end
  end
end


