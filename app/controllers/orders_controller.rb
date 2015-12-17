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

  include PaymentProcessor

  before_filter :authenticate_user!, except: [:new]
  load_and_authorize_resource
  skip_authorize_resource only: [:new]

  def show
    @order = Order.find(params[:id])
    @site_settings = SiteSetting.instance 
    
    respond_to do |format|
      format.html
    end
  end

  def new
    @cart = current_cart
    @site_settings = SiteSetting.instance
    # update the cart in case the user changed any quantitities
    if @cart.update_attributes(params[:cart]) 
      @order = Order.update_or_new(@cart)
      @order.paying_online = params[:paying_online]
      @processor_params = CGI.parse(request.query_string)
    else
      @total_price = @cart.total_price
      render 'cart/index'
    end
  end
  
  def create
    cart = current_cart
    @order = Order.update_or_new(cart)
    @order.paying_online = params[:paying_online]
    respond_to do |format|
      if @order.purchase(cart, params)
        format.html { redirect_to finish_order_path }
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

    respond_to do |format|
      format.html
    end
  end

  def update
    @order = Order.find(params[:id])
    @order.current_user = current_user
    new_cart = @order.begin_update(params[:order])
    if @order.paid_online?
      redirect_to payment_processor.checkout(new_cart, complete_update_url(paying_online: true, cart_id: new_cart.id, order_id: @order.id), edit_order_url(@order))
    else
      if @order.update_and_purchase(new_cart, params)
        redirect_to complete_update_order_path(cart_id: new_cart.id, order_id: @order.id)
      else
        render :edit
      end
    end
  end

  def complete_update
    cart = Cart.find(params[:cart_id])
    order = Order.find(params[:order_id])
    send_emails(order, true)
    cart.destroy
    redirect_to order_path(order), notice: 'Order successfully updated'
  end

  def destroy
    @order = Order.active.find(params[:id])
          
    respond_to do |format|
      if @order.cancel
        format.html { redirect_to site_settings_path, notice: 'Order successfully cancelled' }
      else
        format.html { redirect_to order_path(@order.id), notice: "Order could not be cancelled! Error: #{@order.errors[:base]}" }
      end
    end
  end
  
  private
  
  def send_emails_and_destroy_cart(order, update)
    send_emails(order, update)
    Cart.destroy(session[:cart_id]) if Cart.exists?(session[:cart_id])
    session[:cart_id] = nil
  end
  
  def send_emails(order, update)
    # Send an email to each seller notifying them of the sale
    sellers = order.cart_items.map { |item| item.inventory_item.user }.uniq(&:id)
    if update
      sellers.each do |seller|
        SellerMailer.delay.updated_purchase_mail(seller, order) if seller.user_preference.seller_purchase_notification
      end
    else
      sellers.each do |seller|
        SellerMailer.delay.new_purchase_mail(seller, order) if seller.user_preference.seller_purchase_notification
      end
    end

    BuyerMailer.delay.order_mail(current_user, order)
  end
  
end
