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
  acts_as_singleton
  validates :terms_of_service, :presence => true, :if => :require_terms_of_service?
  before_save :sanitize_html
  
  attr_accessible :site_description, :inventory_guidelines, :terms_of_service, :require_terms_of_service
  
  def require_terms_of_service?
    require_terms_of_service
  end
  
  
  private 
  
  def sanitize_html
    self.site_description = Sanitize.fragment(site_description, Sanitize::Config::RELAXED)
    self.terms_of_service = Sanitize.fragment(terms_of_service, Sanitize::Config::RELAXED)
  end
  
end
