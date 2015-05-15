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
  include Settings
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def index
    respond_to do |format|
      format.html
    end
  end
  
  def update
    respond_to do |format|
      if @site_contents.update(params[:site_content])
        format.html { redirect_to site_contents_path, notice: 'Content Successfully Saved!' }
      else
        format.html { render :index }
      end
    end
  end
end
