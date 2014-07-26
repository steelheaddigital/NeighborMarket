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

class BuyerMailer < BaseMailer
  helper :buyer_mailer
  
  def order_mail(buyer, order)
    @order = order
    @order_pickup_date = OrderCycle.current_cycle.buyer_pickup_date
    @site_settings = SiteSetting.first
    mail( :to => buyer.email, 
          :subject => "Your order summary from #{@site_settings.site_name}")
  end
  
  def order_modified_mail(seller, order)
    @order = order
    @site_settings = SiteSetting.first
    
    mail( :to => @order.user.email,
          :subject => "Your order at #{@site_settings.site_name} has been modified")
  end
  
  def change_request_complete_mail(change_request)
    @request = change_request
    
    mail( :to => change_request.user.email,
          :subject => "Your order change request has been completed")
  end
  
  def order_cycle_end_mail(buyer, order_cycle)
    @order = buyer.orders.find_by_order_cycle_id(order_cycle.id)
    @order_pickup_date = order_cycle.buyer_pickup_date
    @site_settings = SiteSetting.first
    @order_cycle = order_cycle
    
    mail( :to => buyer.email, 
          :subject => "The current order cycle has ended at #{@site_settings.site_name}" )
  end
  
end
