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

class CartController < ApplicationController
  include CurrentCart
  include PaymentProcessor
  
  def index
    @cart = current_cart
    @total_price = @cart.total_price
    
    respond_to do |format|
      format.html { render layout: 'layouts/navigational' }
    end
  end

  def checkout
    if !user_signed_in? || !current_user.buyer?
      render :not_buyer
      return
    end

    @cart = current_cart
    if @cart.update_attributes(params[:cart])
      if params[:commit] == 'Continue Shopping'
        last_search_path = session[:last_search_path]
        if last_search_path.nil?
          redirect_to root_path
        else
          session[:last_search_path] = nil
          redirect_to last_search_path
        end
      elsif params[:commit] == 'Checkout and pay online'
        redirect_to payment_processor.checkout(@cart, new_order_url(paying_online: true), cart_index_url)
      else
        redirect_to new_order_path
      end
    else
      redirect_to :index
    end
  end
  
  def item_count
    @item_count = current_cart.cart_items.count
    
    respond_to do |format|
      format.json { render json: @item_count }
    end
  end
end
