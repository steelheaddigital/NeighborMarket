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

class HomeController < ApplicationController
  def index
    site_settings = SiteSetting.first
    if site_settings
      @site_name = site_settings.site_name
      @site_description = if site_settings.site_description.blank? then "Welcome to the " + @site_name else site_settings.site_description end
    else
      @site_name = "Neighbor Market"
      @site_description = "Welcome to the Neighbor Market"
    end
  end
  
  def user_home
    @seller = current_user.approved_seller?
    @current_order_id = params[:current_order_id]
    @completed_order_id = params[:completed_order_id]
    @manager = current_user.manager?
  end
  
  def refresh
    render :text => "site successfully refreshed \n"
  end

end
