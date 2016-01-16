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
    session[:last_search_path] = nil
    site_settings = SiteSetting.instance
    site_contents = SiteContent.instance
    current_inventory_items = InventoryItem.published.where('inventory_items.photo_file_name IS NOT NULL')
    @items_for_carousel = current_inventory_items.order("RANDOM()")
                          .limit(5)
    @items_for_display = current_inventory_items.paginate(:page => 1, :per_page => 8)
    if site_settings
      @site_name = site_settings.site_name.blank? ? "Neighbor Market" : site_settings.site_name
      @site_description = site_contents.site_description.blank? ? "Welcome to the " + @site_name : site_contents.site_description
    else
      @site_name = "Neighbor Market"
      @site_description = "Welcome to the Neighbor Market"
    end

    render layout: 'layouts/navigational'
  end
  
  def paginate_items
    current_inventory_items = InventoryItem.published.where('inventory_items.photo_file_name IS NOT NULL')
    @items_for_display = current_inventory_items.paginate(:page => params[:page], :per_page => 8)
    
    render "_items", :layout => false
  end
  
  def user_home
    @seller = current_user.approved_seller?
    @current_order_id = params[:current_order_id]
    @completed_order_id = params[:completed_order_id]
    @manager = current_user.manager?
  end
  
  def sitemap
    path = Rails.root.join('public', 'sitemaps', 'sitemap.xml')
    if File.exist?(path)
      render xml: open(path).read
    else
      render text: 'Sitemap not found.', status: :not_found
    end
  end

  def robots
  end
end
