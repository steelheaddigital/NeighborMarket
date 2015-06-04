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

class OrderCycleEndJob
  
  def perform
    current_cycle = OrderCycle.find_by_status('current')
    current_cycle_settings = OrderCycleSetting.first
    if current_cycle_settings.recurring
      padding_interval = current_cycle_settings.padding_interval.to_sym
      interval = current_cycle_settings.interval.pluralize.to_sym
      
      new_start_date = current_cycle.end_date.advance(padding_interval => current_cycle_settings.padding)
      new_end_date = current_cycle.end_date.advance(interval => 1)
      new_seller_delivery_date = current_cycle.seller_delivery_date.advance(interval => 1)
      new_buyer_pickup_date = current_cycle.buyer_pickup_date.advance(interval => 1)
      
      new_cycle = OrderCycle.new(start_date: new_start_date,
                                 end_date: new_end_date,
                                 status: 'pending',
                                 seller_delivery_date: new_seller_delivery_date, 
                                 buyer_pickup_date: new_buyer_pickup_date)
                                 
      if new_cycle.save
        OrderCycle.queue_order_cycle_start_job(new_start_date)
        remove_items_from_orders_where_minimum_not_met(current_cycle.id)
        send_emails(current_cycle)
        queue_post_pickup_job(current_cycle)
      end
    else
      current_cycle.update_column(:status, 'complete')
      remove_items_from_orders_where_minimum_not_met(current_cycle.id)
      send_emails(current_cycle)
      queue_post_pickup_job(current_cycle)
    end
  end
  
  def remove_items_from_orders_where_minimum_not_met(current_order_cycle_id)
    cart_items = CartItem.joins(:order, :inventory_item).where(orders: { order_cycle_id: current_order_cycle_id })
    cart_items.each do |item|
      unless item.inventory_item.minimum_reached_for_order_cycle?(current_order_cycle_id)
        item.update_column(:minimum_reached_at_order_cycle_end, false)
      end
    end
  end
  
  def send_emails(order_cycle)
    sellers = User.joins(:roles).where(roles: { name: 'seller' })
    sellers.each do |seller|
      SellerMailer.order_cycle_end_mail(seller, order_cycle).deliver
    end
    
    orders = Order.where(order_cycle_id: order_cycle.id)
    orders.each do |order|
      if order.has_cart_items_where_order_cycle_minimum_reached?
        BuyerMailer.order_cycle_end_mail(order, order_cycle).deliver
      else
        BuyerMailer.order_cycle_end_mail_no_items(order, order_cycle).deliver
      end
    end
    
  end
  
  def queue_post_pickup_job(order_cycle)
    job = PostPickupJob.new(order_cycle.id)
    send_date = order_cycle.buyer_pickup_date + 1.day
    Delayed::Job.where('queue = ?', 'post_pickup').each(&:destroy)
    Delayed::Job.enqueue(job, priority: 0, run_at: send_date, queue: 'post_pickup')
  end
  
end
