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

class InfoController < ApplicationController
  
  def about
    @site_name = SiteSetting.instance.site_name
    @about_content = SiteContent.instance.about
  end
  
  def privacy
    @site_name = SiteSetting.instance.site_name
  end
  
  def terms
    @site_name = SiteSetting.instance.site_name
    @terms_of_service = SiteContent.instance.terms_of_service
  end
  
end
