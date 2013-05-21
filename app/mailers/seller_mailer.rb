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

class SellerMailer < BaseMailer

  def seller_approved_mail(user)
    @site_settings = SiteSetting.first
    mail(:to => user.email, :subject => "Your #{@site_settings.site_name} Seller Account Is Approved" )
  end
  
  def new_purchase_mail(seller, order)
    site_settings = SiteSetting.first
    subject = "A purchase of your product has been made at #{site_settings.site_name}"
    purchase_mail(seller, order, subject)
  end
  
  def updated_purchase_mail(seller, order)
    site_settings = SiteSetting.first
    subject = "An order containing your product has been updated at #{site_settings.site_name}"
    purchase_mail(seller, order, subject)
  end
  
  def order_cycle_end_mail(seller, order_cycle)
    @site_settings = SiteSetting.first
    @seller = seller
    @order_cycle = order_cycle
    @orders = Order.joins(:cart_items => :inventory_item)
                   .select('orders.id, orders.user_id')
                   .where(:inventory_items => {:user_id => seller.id}, :orders => {:order_cycle_id => order_cycle.id})
                   .group('orders.id, orders.user_id')
    @inventory_items = InventoryItem.joins(:cart_items => :order)
                                .where('inventory_items.user_id = ? AND orders.order_cycle_id = ?', seller.id, order_cycle.id)
                                .select('inventory_items.id, inventory_items.name, inventory_items.price_unit, sum(cart_items.quantity)')
                                .group('inventory_items.id, inventory_items.name, inventory_items.price_unit')
    
    unless @orders.empty?
      packing_list = PackingList.new.to_pdf(@orders, @seller)
      pick_list = PickList.new.to_pdf(@inventory_items)
      attachments['packing_list.pdf'] = packing_list
      attachments['pick_list.pdf'] = pick_list
    end
    mail( :to => seller.email, 
          :subject => "The current order cycle has ended at #{@site_settings.site_name}")
  end
  
  def change_request_complete_mail(change_request)
    @request = change_request
    
    mail( :to => change_request.user.email,
          :subject => "Your inventory item change request has been completed")
  end
  
  private
  
  def purchase_mail(seller, order, subject)
    @buyer = order.user
    @cart_items = order.cart_items.joins(:inventory_item).where("inventory_items.user_id = ?", seller.id)
    mail( :to => seller.email, 
          :subject => subject)
  end
  
end
