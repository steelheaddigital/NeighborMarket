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

class SiteContentsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def index
    @site_settings = SiteSetting.first ? SiteSetting.first : SiteSetting.new
    @site_contents = SiteContent.first ? SiteContent.first : SiteContent.new
    
    respond_to do |format|
      format.html
    end
  end
  
  def update
    @site_contents = SiteContent.new_content(params[:site_content])
    @site_settings = SiteSetting.first
    
    respond_to do |format|
      if @site_contents.save
        format.html { redirect_to site_contents_path, notice: 'Content Successfully Saved!'}
      else
        format.html { render :index }
      end
    end
  end

end