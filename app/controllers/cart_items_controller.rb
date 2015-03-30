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

class CartItemsController < ApplicationController
  include CurrentCart
  load_and_authorize_resource :only => [:destroy]
  before_action :set_cart, only: [:create]
  
  def create
    @cart = current_cart
    inventory_item_id = params[:inventory_item_id]
    quantity = params[:quantity]
    @cart_item = @cart.add_inventory_item(inventory_item_id, quantity)
    
    respond_to do |format|
      if @cart_item.save
        format.html { redirect_to cart_index_path }
      else
        message = @cart_item.errors.full_messages.first
        format.html { redirect_to :back, notice: message }
      end
    end
    
  end
  
  def destroy
    @cart_item = CartItem.find(params[:cart_item_id])
    @cart_item.current_user = current_user
      
    respond_to do |format|
      if @cart_item.destroy
        if @cart_item.order_id
          if Order.exists?(@cart_item.order_id)
            format.html{ redirect_to edit_order_path(@cart_item.order_id) }
          else
            format.html{redirect_to order_change_requests_management_index_path, notice: "All Items in the order have been deleted. The order has been cancelled."}
          end
        else
          format.html{ redirect_to cart_index_path }
        end 
      else
        format.html{ redirect_to cart_index_path, notice: "Cart item could not be deleted" }
      end
    end
  end
  
end
