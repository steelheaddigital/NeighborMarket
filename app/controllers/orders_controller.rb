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

class OrdersController < ApplicationController
  include CurrentCart

  before_filter :authenticate_user!, except: [:new]
  load_and_authorize_resource
  skip_authorize_resource only: [:new]

  def new
    @cart = current_cart
    @site_settings = SiteSetting.instance
    # update the cart in case the user changed any quantitities
    if @cart.update_attributes(params[:cart]) 

      if params[:commit] == 'Continue Shopping'
        last_search_path = session[:last_search_path]
        if last_search_path.nil?
          redirect_to root_path
        else
          session[:last_search_path] = nil
          redirect_to last_search_path
        end

        return
      end

      if !user_signed_in? || !current_user.buyer?
        render :not_buyer
        return
      end

      @order = Order.update_or_new(@cart)
      @processor_params = CGI.parse(request.query_string)
    else
      @total_price = @cart.total_price
      render 'cart/index'
    end
    
  end
  
  def create
    @order = Order.update_or_new(current_cart)
    purchase_redirect_url = @order.purchase(current_cart, params)
    respond_to do |format|
      if purchase_redirect_url
        format.html { redirect_to purchase_redirect_url }
      else
        message = "Your order could not be processed because #{@order.errors.full_messages.first}"
        format.html { redirect_to cart_index_path, notice: message }
      end
    end
  end
  
  def finish
    @order = current_user.current_order
    @order_pickup_date = OrderCycle.current_cycle.buyer_pickup_date
    @site_settings = SiteSetting.instance
    send_emails_and_destroy_cart(@order, false)

    respond_to do |format|
      format.html
    end
  end
  
  def edit
    @order = Order.find(params[:id])
    @total_price = @order.total_price
    
    respond_to do |format|
      format.html
    end
  end
  
  def update
    @order = Order.find(params[:id])
    @order.current_user = current_user
    
    respond_to do |format|
      if @order.update_attributes(params[:order])
        send_emails(@order, true)
        format.html { redirect_to edit_order_path, notice: 'Order successfully updated!' }
      else
        @total_price = @order.total_price
        format.html { render 'edit' }
      end
    end
  end
  
  def show
    @order = Order.find(params[:id])
    @site_settings = SiteSetting.instance 
    
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @order = Order.find(params[:id])
          
    respond_to do |format|
      if @order.cancel
        format.html { redirect_to site_setting_management_index_path, notice: 'Order successfully cancelled' }
      else
        format.html { redirect_to edit_order_path(@order.id), notice: "Order could not be cancelled! Error: #{@order.errors[:base]}" }
      end
    end
  end
  
  private
  
  def send_emails_and_destroy_cart(order, update)
    send_emails(order, update)
    Cart.destroy(session[:cart_id])
    session.delete(:cart_id)
  end
  
  def send_emails(order, update)
    # Send an email to each seller notifying them of the sale
    sellers = order.cart_items.map { |item| item.inventory_item.user }.uniq(&:id)
    if update
      sellers.each do |seller|
        SellerMailer.delay.updated_purchase_mail(seller, order)
      end
    else
      sellers.each do |seller|
        SellerMailer.delay.new_purchase_mail(seller, order)
      end
    end

    BuyerMailer.delay.order_mail(current_user, order)
  end
  
end
