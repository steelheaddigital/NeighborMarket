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

module UserRegistrationsHelper

  def delivery_instructions_message(site_settings)
    if site_settings.delivery_only?
    	"<h5>Please add delivery instructions to your profile. Your delivery address is the address you have already entered when you set up your seller profile.</h5>".html_safe
    elsif site_settings.all_modes?
    	"<h5>If you would like to have the option of having your orders delivered, please enter delivery instructions now, otherwise you will need to pick up your order at the drop point. Your delivery address is the address you have already entered when you set up your seller profile.</h5>".html_safe
    elsif site_settings.drop_point_only?
      "<h5> We have all the information we need to create your buyer account! Just click the update button to confirm. </h5>".html_safe
    end
  end

  def delivery_instructions_label(site_settings)
    if site_settings.delivery_only?
    	"Delivery Instructions*"
    else
      "Delivery Instructions"
    end
  end
  
  def field_label(field_name, site_settings)
    field_labels(site_settings)[field_name]
  end
  
  
  private
  
  def field_labels(site_settings)
    if site_settings.delivery_only?
    	{ :address => "Delivery Address*",
        :city => "Delivery City*",
        :country => "Delivery Country*",
        :state => "Delivery State*",
        :zip => "Delivery Zip*"
      }
    else
    	{ :address => "Delivery Address",
        :city => "Delivery City",
        :country => "Delivery Country",
        :state => "Delivery State",
        :zip => "Delivery Zip"
      }
    end
  end

end