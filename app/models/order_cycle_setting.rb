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

class OrderCycleSetting < ActiveRecord::Base
  has_many :order_cycles
  attr_accessible :recurring, :interval, :padding, :padding_interval
  
  validates :interval, :presence => true, :if => 'recurring?'
  validates :padding, :numericality => { :only_integer => true }
  
  def self.new_setting(settings)
    current_order_cycle_settings = self.first
    if current_order_cycle_settings
      current_order_cycle_settings.assign_attributes(settings)
      return current_order_cycle_settings
    else
      new_settings = self.new(settings)
      return new_settings
    end
  end
  
end
