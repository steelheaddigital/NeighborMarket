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

class OrderCycleStartJob
  include Sidekiq::Worker

  def perform
    pending_cycle = OrderCycle.find_by_status('pending')
    pending_cycle.status = 'current'
    if pending_cycle.save
      OrderCycle.queue_order_cycle_end_job(pending_cycle.end_date)
      InventoryItem.autopost(pending_cycle)
      pending_cycle.queue_reccomendation_mail_job
      
      sellers = User.active_sellers.joins(:user_preference).where(user_preferences: { seller_new_order_cycle_notification: true })
      sellers.each do |seller|
        seller.save if seller.authentication_token.blank? #generate an auth token
        SellerMailer.order_cycle_start_mail(seller, pending_cycle).deliver_now
      end
    end
  end
  
end
