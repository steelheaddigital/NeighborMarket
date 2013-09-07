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

class TopLevelCategory < ActiveRecord::Base
  has_many :second_level_categories
  has_one :inventory_item
  
  attr_accessible :name, :description, :active
  
  validates :name, :presence => true
  
  def deactivate
    update_column(:active, false)
    self.second_level_categories.each do |category|
      category.deactivate
    end
  end
  
end
