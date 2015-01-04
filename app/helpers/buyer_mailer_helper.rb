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

module BuyerMailerHelper
  include ApplicationHelper

  def pickup_instructions(order_pickup_date, order)
    site_settings = SiteSetting.instance
    if site_settings.delivery_only?
      delivery_message(order_pickup_date, order)
    elsif site_settings.all_modes?
    	if order.deliver
        delivery_message(order_pickup_date, order)
      else
        pickup_message(order_pickup_date)
      end
    elsif site_settings.drop_point_only?
      pickup_message(order_pickup_date)
    end
  end
  
  private
  
  def delivery_message(order_pickup_date, order)
    site_settings = SiteSetting.instance
    html = ''
    html += '<div style="padding-bottom: 15px;">' +
      '<div style="padding:10px; border: 3px solid gray;">' +
        '<h5>Your order will be delivered on ' + format_date_time(order_pickup_date) + ' to the following address:</h5><br>' +
        '<div style="padding-left: 30px;">' +
          '<strong>' + order.user.address + '</strong><br>' +
          '<strong>' + order.user.city + ", " + order.user.state + " " + order.user.zip.to_s + '</strong><br>' +
        '</div>' +
      '</div>' +
    '</div>'
    
    html.html_safe
  end
  
  def pickup_message(order_pickup_date)
    site_settings = SiteSetting.instance
    html = ''
    html += '<div style="padding-bottom: 15px;">' +
      '<div style="padding:10px; border: 3px solid gray;">' +
        '<h5>Your order will be available for pickup on ' + format_date_time(order_pickup_date) + ' at the following address:</h5><br>' +
        '<div style="padding-left: 30px;">' +
          '<strong>' + site_settings.drop_point_address + '</strong><br>' +
          '<strong>' + site_settings.drop_point_city + ", " + site_settings.drop_point_state + " " + site_settings.drop_point_zip.to_s + '</strong><br>' +
          '<p>' + "#{site_settings.directions if !site_settings.directions.nil?}" + '</p>' +
        '</div>' +
      '</div>' +
    '</div>'
    
    html.html_safe
  end
  
end