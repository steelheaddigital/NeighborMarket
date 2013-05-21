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

class ManagerMailer < BaseMailer
  
  def new_seller_mail(user, manager)
    @user = user
    @site_settings = SiteSetting.first
    mail( :to => manager.email, 
          :subject => "New seller has signed up at #{@site_settings.site_name} - Pending Verification" )
  end
  
  def inventory_approval_required(seller, manager, inventory_item)
    @seller = seller
    @inventory_item = inventory_item
    @site_settings = SiteSetting.first
    
    mail( :to => manager.email,
          :subject => "#{seller.username} at #{@site_settings.site_name} has posted an inventory item that needs approval")
    
  end
  
  def inventory_item_change_request(manager, description, inventory_item)
    @inventory_item = inventory_item
    @description = description
    site_settings = SiteSetting.first
    
    mail( :to => manager.email,
          :subject => "#{@inventory_item.user.username} at #{site_settings.site_name} has requested a change to an inventory item")
  end
  
  def order_change_request(manager, description, order)
    @order = order
    @description = description
    site_settings = SiteSetting.first
    
    mail( :to => manager.email,
          :subject => "#{@order.user.username} at #{site_settings.site_name} has requested a change to an order")
  end
  
end
