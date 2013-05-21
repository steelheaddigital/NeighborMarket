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
  
  attr_accessible :site_name, :drop_point_address, :drop_point_city, :drop_point_state, :drop_point_zip, :time_zone
  
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
  
end
