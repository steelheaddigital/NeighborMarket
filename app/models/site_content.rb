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

class SiteContent < ActiveRecord::Base 
  validates :terms_of_service, :presence => true, :if => :require_terms_of_service?
  
  attr_accessible :site_description, :inventory_guidelines, :terms_of_service, :require_terms_of_service
  
  def self.new_content(contents)
    current_contents = self.first
    if current_contents
      current_contents.assign_attributes(contents)
      return current_contents
    else
      new_contents = self.new(contents)
      return new_contents
    end
  end
  
  def require_terms_of_service?
    require_terms_of_service
  end
  
end
