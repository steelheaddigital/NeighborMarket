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

module CurrentCart
  extend ActiveSupport::Concern
  
  def set_cart
    Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound    
    if(user_signed_in?)
      cart = Cart.create(:user_id => current_user.id)
    else
      cart = Cart.create
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