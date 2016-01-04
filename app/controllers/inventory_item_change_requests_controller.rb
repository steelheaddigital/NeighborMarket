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

class InventoryItemChangeRequestsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  

  def index
    @requests = InventoryItemChangeRequest.active
    
    respond_to do |format|
      format.html
    end
  end

  def new
    @item = InventoryItem.find(params[:inventory_item_id])
    @request = current_user.inventory_item_change_requests.build
    
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @item = InventoryItem.find(params[:inventory_item_id])
    @request = current_user.inventory_item_change_requests.build(params[:inventory_item_change_request])
    @request.inventory_item = @item
    
    respond_to do |format|
      if @request.save
        managers = User.joins(:roles).where('roles.name = ?', "manager")
        managers.each do |manager|
          ManagerMailer.delay.inventory_item_change_request(manager, @request.description, @item)
        end
        format.html { redirect_to seller_index_path, notice: "Change request successfully sent."}
      else
        format.html { render :new }
      end
    end    
  end
  
  def complete
    request = InventoryItemChangeRequest.find(params[:id])
    request.complete = true
    
    respond_to do |format|
      if request.save
        SellerMailer.delay.change_request_complete_mail(request)
        format.html { redirect_to inventory_item_change_requests_path, notice: "Request successfully completed."}
      else
        format.html { redirect_to inventory_item_change_requests_path, notice: "Request could not be completed."}
      end
    end
  end
  
end