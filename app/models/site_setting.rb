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

class SiteSetting < ActiveRecord::Base 
  validates_format_of :drop_point_zip,
                      :with => %r{\d{5}(-\d{4})?},
                      :message => "should be like 12345 or 12345-1234",
                      :allow_blank => true
                      
  validate :must_have_at_least_one_mode
  validate :must_have_facebook_app_id_if_facebook_enabled
  
  attr_accessible :site_name, :drop_point_address, :drop_point_city, :drop_point_state, :drop_point_zip, :time_zone, :drop_point, :delivery, :directions, :facebook_enabled, :facebook_app_id, :reputation_enabled
  
  def self.new_setting(settings)
    current_site_settings = self.first
    if current_site_settings
      current_site_settings.assign_attributes(settings)
      return current_site_settings
    else
      new_settings = self.new(settings)
      return new_settings
    end
  end
  
  def delivery_only?
    delivery == true && drop_point == false
  end
  
  def drop_point_only? 
    drop_point == true && delivery == false
  end
  
  def all_modes?
    drop_point == true && delivery == true
  end
  
  def site_mode
    if delivery_only?
      "delivery"
    elsif drop_point_only?
      "drop_point"
    elsif all_modes?
      "all"
    end
  end
  
  def must_have_at_least_one_mode
    if !drop_point and !delivery
      errors.add(:base, "At least one site mode must be enabled")
    end
  end  
  
  def must_have_facebook_app_id_if_facebook_enabled
    if facebook_enabled && facebook_app_id.blank?
      errors.add(:facebook_app_id, "must be provided to enable Facebook integration")
    end
  end
  
end
