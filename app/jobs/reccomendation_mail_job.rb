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

class ReccomendationMailJob
  include Sidekiq::Worker
  
  def perform 
    return if InventoryItem.published.nil? || InventoryItem.published.count == 0
    buyers = User.active_buyers.joins(:user_preference).where(user_preferences: { buyer_new_order_cycle_notification: true })
    buyers.each do |buyer|
      buyer.save if buyer.authentication_token.blank? #generate an auth token
      BuyerMailer.reccomendation_mail(buyer).deliver_now
    end
  end
  
end
